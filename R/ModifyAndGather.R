# remove type annotation
remove_type_annotation <- function(code, env) {
  if (!is.call(code)) {
    return(code)
  }
  code <- as.list(code)
  if (deparse(code[[1]]) == "::") {
    code <- code[[2]]
    remove_type_annotation(code, env)
  }

  lapply(code, function(x) {
    remove_type_annotation(x, env)
  })
}

to_call <- function(ast) {
  for (i in seq_along(ast)) {
    if (is.list(ast[[i]])) {
      if (length(ast[[i]]) == 1) {
        ast[[i]] <- as.name(unlist(ast[[i]])[[1]])
      } else {
        ast[[i]] <- to_call(ast[[i]])
      }
    }
  }
  ast <- as.call(ast)
  return(ast)
}

mod_and_gather <- function(code, env) {
  ast <- remove_type_annotation(code, env)
  to_call(ast)
}

# gather var on rhs
gather_var_rhs <- function(code, env) {
  if (!is.call(code)) {
    return(code)
  }
  if ((deparse(code[[1]]) == "<-") || (deparse(code[[1]]) == "=")) {
    env$vars <- all.vars(code[[3]])
    return()
  }
  code <- as.list(code)
  lapply(code, function(x) {
    gather_var_rhs(x, env)
  })
}

nvars_rhs <- function(code) {
  env <- new.env()
  env$vars <- NULL
  gather_var_rhs(code, env)
  return(length(env$vars))
}

# identify type of var on lhs
get_var_lhs <- function(code, symbol_table) {
  code <- as.list(code)
  if (is.language(code[[2]]) && !is.symbol(code[[2]])) {
    temp <- deparse(code[[2]][[2]])
    return(list(
      var_idx =
        symbol_table[
          symbol_table$variables == temp,
          "ids"
        ] - 1,
      type =
        symbol_table[
          symbol_table$variables == temp,
          "types"
        ]
    ))
  }
  return(list(
    var_idx =
      symbol_table[
        symbol_table$variables == deparse(code[[2]]),
        "ids"
      ] - 1,
    type =
      symbol_table[
        symbol_table$variables == deparse(code[[2]]),
        "types"
      ]
  ))
}

# get all vars at rhs
gather_rhs <- function(code) {
  if (!is.call(code)) {
    return(code)
  }
  if ((deparse(code[[1]]) == "<-") || (deparse(code[[1]]) == "=")) {
    return(code[[3]])
  }
  code <- as.list(code)
  lapply(code, gather_rhs)
}

extract_vars_from_rhs <- function(code, env) {
  if (!is.call(code)) {
    if (!(deparse(code) %in% permitted_fcts()) &&
      !rlang::is_scalar_double(code) &&
      !rlang::is_scalar_logical(code) &&
      !rlang::is_scalar_integer(code)) {
      env$vars <- c(env$vars, code)
    }
    return(code)
  }
  code <- as.list(code)
  lapply(code, function(x) {
    extract_vars_from_rhs(x, env)
  })
}

get_all_vars_rhs <- function(code) {
  env <- new.env()
  env$vars <- NULL
  code_rhs <- gather_rhs(code)
  extract_vars_from_rhs(code_rhs, env)
  return(env$vars)
}

gather_expr <- function(env) {
  env$EXPRESSIONS <- lapply(env$EXPRESSIONS, function(x) {
    temp <- mod_and_gather(x, env)
    temp <- unlist(temp)
    temp <- list(
      EXPR = temp,
      var_left = get_var_lhs(temp, env$symbol_table),
      variables = get_all_vars_rhs(temp),
      nvars = nvars_rhs(temp)
    )
    return(Filter(function(x) length(x) >= 1, temp))
  })
}
