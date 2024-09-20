f <- function() {
  a %type% integer <- 1L
  a <- a + 1 + b * a + c
  b <- b + b
}
library(scR)
# res <- traverse(f)
# trash <- lapply(res, cat)

# Function to get the Abstract Syntax Tree (AST) of the code
get_ast <- function(code) {
  if (!is.call(code)) {
    return(code)
  }
  code <- as.list(code)
  lapply(code, get_ast)
}

source("Nodes.R")
source("Utils.R")
source("CreateAst.R")
source("PrintAst.R")

# Example code to create AST
fct <- function() {
  a <- b + c - d * e + 7
  a <- d * e - b + c
  if (a) {
    a <- a + 1
  } else if (`invalid2`(b)) {
    b <- `invalid`(b) + 1
    b <- b * b + bla() + 1
  } else {
    c <- c %/% 2 + 3.14
  }
}

translate(fct) |> cat()
