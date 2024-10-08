check_expr <- function(code) {
  if (grepl("EXPR", deparse(code)) || grepl("VAR", deparse(code)) ||
    grepl("SUBSET", deparse(code))) {
    stop("Variables are not allowed to have 'EXPR', 'SUBSET'
      or 'VAR' within their names")
  }
}

save_type <- function(code, env) {
  code <- as.list(code)
  if (deparse(code[[1]]) == "for") {
    env$types <-
      rbind(
        env$types,
        data.frame(name = deparse(code[[2]]), type = quote("ForLoop"))
      )
  }
  if (deparse(code[[1]]) == "%type%") {
    if (deparse(code[[3]]) %in% env$permitted_types) {
      env$types <-
        rbind(
          env$types,
          data.frame(name = deparse(code[[2]]), type = deparse(code[[3]]))
        )
    } else {
      stop(paste("Found unknown type: ", deparse(code[[3]])))
    }
  }
}

save_symbol <- function(code, env) {
  if (!is.list(code) && is.symbol(code)) {
    check_expr(code)
    if ((deparse(code) %in% env$permitted_types) ||
      (deparse(code) %in% env$permitted_fcts)) {
      return()
    }
    env$symbols[[length(env$symbols) + 1]] <- deparse(code)
  }
}

save_expressions <- function(code, env) {
  temp <- as.list(code)
  if ((deparse(temp[[1]]) == "<-") || (deparse(temp[[1]]) == "=")) {
    env$EXPRESSIONS <-
      c(
        (env$EXPRESSIONS),
        code
      )
  }
}

gather_vars_types <- function(code, env) {
  if (!is.call(code)) {
    return(code)
  }
  save_type(code, env)
  save_expressions(code, env)

  code <- as.list(code)

  if (deparse(code[[1]]) %in% env$prohibited_functions) {
    stop(paste("Found function: ", code[[1]],
      "which is not supported",
      collapse = ""
    ))
  }
  for (i in seq_along(code)) {
    save_symbol(code[[i]], env)
  }

  lapply(code, function(x) {
    gather_vars_types(x, env)
  })
}


assemble_symbol_table <- function(variables, variable_type_pairs,
                                  constants_num, constants_int, constants_log) {
  if (length(unique(variable_type_pairs$name)) !=
    length(variable_type_pairs$name)) {
    temp <- unique(variable_type_pairs$name)
    for (i in seq_along(temp)) {
      if (length(which(temp[[i]] == variable_type_pairs$name)) > 1) {
        stop(paste("The type for variable:", temp[[i]], "was defined twice"))
      }
    }
  }
  vars <- unique(variables)
  ids <- seq_along(vars) - 1
  df <- data.frame(ids = ids, variables = unlist(vars))
  df$types <- variable_type_pairs[match(
    df$variables,
    variable_type_pairs$name
  ), 2]
  df[is.na(df$types), "types"] <- "double_vector"
  return(df)
}

create_symbol_table <- function(env, f) {
  env$prohibited_functions <- prohibited_functions()
  env$permitted_fcts <- permitted_fcts()
  env$permitted_types <- permitted_types()

  env$EXPRESSIONS <- list()
  b <- body(f)[2:length(body(f))]
  env$symbols <- list()
  env$types <- data.frame(name = NULL, type = NULL)
  ast <- list()
  for (i in seq_along(b)) {
    ast[[i]] <- gather_vars_types(b[[i]], env)
  }
  symbol_table <- assemble_symbol_table(env$symbols, env$types)
  env$symbol_table <- symbol_table
  return(symbol_table)
}
