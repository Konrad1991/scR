f <- function() {
  a %type% integer <- 1L
  a <- a + 1 + b * a + c
  b <- b + b
}
library(scR)
res <- traverse(f)
trash <- lapply(res, cat)

stop()

get_ast <- function(code) {
  if (!is.call(code)) {
    return(code)
  }
  code <- as.list(code)
  lapply(code, get_ast)
}

is_var <- function(x) {
  is.symbol(x) && !is.call(x)
}

Node <- R6::R6Class(
  "Node",
  public = list(root = "root")
)

BinaryNode <- R6::R6Class(
  "BinaryNode",
  inherit = Node,
  public = list(
    operator = NULL,
    left_node = NULL,
    right_node = NULL,
    initialize = function() {}
  )
)

UnaryNode <- R6::R6Class(
  "UnaryNode",
  inherit = Node,
  public = list(
    operator = NULL,
    obj = NULL,
    initialize = function() {}
  )
)

create_ast <- function(code) {
  code <- as.list(code)
  bn <- BinaryNode$new()
  bn$operator <- deparse(code[[1]])
  if (!is.symbol(code[[3]]) && is.call(code[[3]])) {
    bn$right_node <- create_ast(code[[3]])
  } else {
    bn$right_node <- code[[3]] |> deparse()
  }
  if (!is.symbol(code[[2]]) && is.call(code[[2]])) {
    bn$left_node <- create_ast(code[[2]])
  } else {
    bn$left_node <- code[[2]] |> deparse()
  }
  return(bn)
}

code <- quote(a <- b + c - d * e)
ast <- create_ast(code)

print_ast <- function(ast, indent = "") {
  if (inherits(ast, "BinaryNode")) {
    cat("Operator: ", indent, ast$operator, "\n")
    indent <- paste0(indent, "  ")
    print_ast(ast$left_node, indent)
    print_ast(ast$right_node, indent)
  } else {
    cat("Symbol: ", indent, ast, "\n")
  }
}

print_ast(ast)


# get_ast(code) |> str()
# List of 3
#  $ : symbol <-
#  $ : symbol a
#  $ :List of 3
#   ..$ : symbol -
#   ..$ :List of 3
#   .. ..$ : symbol +
#   .. ..$ : symbol b
#   .. ..$ : symbol c
#   ..$ :List of 3
#   .. ..$ : symbol *
#   .. ..$ : symbol d
#   .. ..$ : symbol e
