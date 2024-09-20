# Fuection to process the code and create the AST
process <- function(code, env, check) {
  if (!is.symbol(code) && is.call(code)) {
    return(create_ast(code, env, check))
  }
  return(deparse(code))
}

# Function to create the AST based on the code
create_ast <- function(code, env, check) {
  code <- as.list(code)
  operator <- deparse(code[[1]])
  error_message <- check_expr(
    check_function(operator),
    paste0("Invalid operator: ", operator), check
  )
  if (operator == "if") {
    if_node <- IfNode$new()
    if_node$line <- env$line
    if_node$error <- error_message
    if_node$condition <- code[[2]] |> process(env, check)
    if_node$true_node <- code[[3]] |> process(env, check)
    if (length(code) == 4) {
      increment_line(env)
      if_node$false_node <- code[[4]] |> process(env, check)
    }
    return(if_node)
  } else if (operator == "{") {
    b_node <- BlockNode$new()
    b_node$line <- env$line # NOTE: is the start line of the block
    b_node$error <- error_message
    b_node$block <- lapply(code[-1], function(line) {
      increment_line(env)
      process(line, env, check)
    })
    return(b_node)
  } else if (length(code) == 3) { # NOTE: Binary operators
    bn <- BinaryNode$new()
    bn$line <- env$line
    bn$error <- error_message
    bn$operator <- operator
    bn$right_node <- code[[3]] |> process(env, check)
    bn$left_node <- code[[2]] |> process(env, check)
    return(bn)
  } else if (length(code) == 2) { # NOTE: Unary operators
    un <- UnaryNode$new()
    un$line <- env$line
    un$error <- error_message
    un$operator <- operator
    un$obj <- code[[2]] |> process(env, check)
    return(un)
  } else if (length(code) == 1) { # NOTE: Nullary operators
    nn <- NullaryNode$new()
    nn$line <- env$line
    nn$error <- error_message
    nn$operator <- operator
    return(nn)
  }
}

translate <- function(fct) {
  b <- body(fct)
  if (b[[1]] == "{") {
    b <- b[2:length(b)]
  }
  env <- new.env()
  env$line <- 1
  code_string <- list()
  ast <- NULL
  for (i in seq_along(b)) {
    old_line <- env$line
    e <- try(ast <- process(b[[i]], env, TRUE), silent = TRUE)
    if (inherits(e, "try-error")) {
      wrong_ast <- process(b[[i]], env, FALSE)
      wrong_ast <- wrong_ast$stringify()
      print(attributes(e)$condition)
      cat(wrong_ast)
      return()
    } else {
      ast <- e
    }
    try({
      print_ast(ast)
      code_string[[i]] <- ast$stringify()
    })
    if (env$line == old_line) {
      env$line <- env$line + 1
    }
    cat("\n")
  }
  return(combine_strings(code_string))
}
