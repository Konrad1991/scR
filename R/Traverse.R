#' @export
traverse <- function(f) {
  # create symbol table and EXPR list
  e <- new.env()
  create_symbol_table(e, f)

  # gather variable, type and expr
  gather_expr(e)

  # create code
  create_code(e)
}
