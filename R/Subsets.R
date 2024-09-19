gather_subsets_internal <- function(code, env) {
  if (!is.call(code)) {
    return(code)
  }
  code <- as.list(code)
  if (deparse(code[[1]]) == "[") {
    if (!env$first_subset) {
      env$first_subset <- TRUE
      env$subset_idx <- env$subset_idx + 1
      env$subsets <- c(env$subsets, as.call(code))
      lapply(code, function(x) {
        gather_subsets_internal(x, env)
      })
      env$first_subset <- FALSE
      as.name(paste0("SUBSET", env$subset_idx))
    }
  } else {
    lapply(code, function(x) {
      gather_subsets_internal(x, env)
    })
  }
}

gather_subsets <- function(env, fct) {
  b <- body(fct)
  env$subsets <- list()
  env$first_subset <- FALSE
  env$subset_idx <- 0
  lapply(b[-1], function(expr) {
    expr <- gather_subsets_internal(expr, env)
  })
  print(env$subsets)
}

determine_what_is_subsetted <- function(code, symbol_table) {
  what <- data.frame(
    types = c(
      "logical_vector", "integer_vector", "double_vector"
    ),
    subset_fcts = c(
      "lv", "iv", "nv"
    ),
    i_needed = c(
      rep(FALSE, 3),
      rep(TRUE, 3)
    )
  )
  var <- deparse(as.list(code)[[2]])
  type <- symbol_table[symbol_table$variables == var, "types"]
  stopifnot(type %in% what$types)
  what[what$types == type, "subset_fcts"] |> unique()
}

with_what <- function() {
  return(
    data.frame(
      types = c(
        "logical", "integer", "double",
        "logical_vector", "integer_vector", "double_vector"
      ),
      subset_fcts = c(
        "ls", "is", "ds",
        "lv", "iv", "dv"
      )
    )
  )
}

with_what_is_subsetted <- function(code, symbol_table) {
  code <- as.list(code)
  code3 <- code[[3]]
  with_what <- with_what()
  if (rlang::is_scalar_logical(code3)) {
    what <- determine_what_is_subsetted(code, symbol_table)
    return(c(what, "ls"))
  } else if (rlang::is_scalar_integer(code3)) {
    what <- determine_what_is_subsetted(code, symbol_table)
    return(c(what, "is"))
  } else if (rlang::is_scalar_double(code3)) {
    what <- determine_what_is_subsetted(code, symbol_table)
    return(c(what, "ds"))
  } else if (is.name(code3)) {
    var <- deparse(code3)
    type <- symbol_table[symbol_table$variables == var, "types"]
    stopifnot(type %in% with_what$types)
    res <- with_what[with_what$types == type, "subset_fcts"] |> unique()
    what <- determine_what_is_subsetted(code, symbol_table)
    return(c(what, res))
  } else {
    what <- determine_what_is_subsetted(code, symbol_table)
    with_what <- determine_what_is_subsetted(as.list(code)[[3]], symbol_table)
    res <- with_what_is_subsetted(
      code3, symbol_table
    )
    return(c(what, res))
  }
}

what_sub <- function(code) {
  code <- as.list(code)
  code3 <- code[[3]]
  if (rlang::is_scalar_logical(code3)) {
    res <- deparse(as.list(code)[[2]])
    return(res)
  } else if (rlang::is_scalar_integer(code3)) {
    res <- deparse(as.list(code)[[2]])
    return(res)
  } else if (rlang::is_scalar_double(code3)) {
    res <- deparse(as.list(code)[[2]])
    return(res)
  } else if (is.name(code3)) {
    res <- deparse(as.list(code)[[2]])
    return(res)
  } else {
    res <- what_sub(as.list(code)[[3]])
    return(c(deparse(as.list(code)[[2]]), res))
  }
}

with_what_sub <- function(code) {
  code <- as.list(code)
  code3 <- code[[3]]
  if (rlang::is_scalar_logical(code3)) {
    res <- deparse(as.list(code)[[3]])
    return(res)
  } else if (rlang::is_scalar_integer(code3)) {
    res <- deparse(as.list(code)[[3]])
    return(res)
  } else if (rlang::is_scalar_double(code3)) {
    res <- deparse(as.list(code)[[3]])
    return(res)
  } else if (is.name(code3)) {
    res <- deparse(as.list(code)[[3]])
    return(res)
  } else {
    res <- with_what_sub(as.list(code)[[3]])
    return(c(deparse(as.list(code)[[3]]), res))
  }
}

def_fcts <- function(vec) {
  n <- length(vec)
  first <- TRUE
  res <- character(n - 1)
  for (i in (n - 1):1) {
    if (first) {
      res[i] <- paste0("get_", vec[i], "_", vec[i + 1]) # TODO: add set
      first <- FALSE
      next
    }
    res[i] <- paste0("get_", vec[i], "_", vec[i + 1], "Sub") # TODO: add set
  }
  return(res)
}

identify_subsets <- function(f, symbol_table) {
  env <- new.env()
  gather_subsets(env, f)

  for (i in seq_along(env$subsets)) {
    res <- with_what_is_subsetted(env$subsets[[i]], symbol_table)
    fcts <- def_fcts(res)
    what <- what_sub(env$subsets[[i]])
    with_what <- with_what_sub(env$subsets[[i]])
    temp <- list()
    for (j in rev(seq_along(fcts))) {
      if (j == length(fcts)) {
        temp[[j]] <- paste0(
          fcts[j], "(", i, ",",
          what[j], ",", with_what[j], ", vm)"
        )
      } else if (j > 1) {
        temp[[j]] <- paste0(fcts[j], "(", i, ", ", "%s", " , vm)")
      } else {
        temp[[j]] <- paste0(fcts[j], "(", i, ", ", "%s", " , vm)")
      }
    }
    if (length(fcts) >= 2) {
      for (j in rev(seq_along(fcts))) {
        if (j < length(fcts)) {
          temp[[j]] <- sprintf(temp[[j]], temp[[j + 1]])
        }
      }
    }
    temp <- temp[[1]]

    print(temp)
    cat("\n\n")
  }
}

# f <- function() {
#   d <- c[1]
#   d <- a[b[1L]]
#   d <- a[b[d[1]]]
#   return(d)
# }
#
# symbol_table <- data.frame(
#   ids = 1:4,
#   variables = c("a", "b", "c", "d"),
#   types = c("double_vector", "integer_vector", "double_vector", "double_vector")
# )
#
# identify_subsets(f, symbol_table)
