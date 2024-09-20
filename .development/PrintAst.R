# Function to print the AST
print_ast <- function(ast, indent = "") {
  if (inherits(ast, "BinaryNode")) {
    cat(indent, ast$line, " Binary: ", ast$operator, "\n")
    indent <- paste0(indent, "  ")
    print_ast(ast$left_node, indent)
    print_ast(ast$right_node, indent)
  } else if (inherits(ast, "UnaryNode")) {
    cat(indent, ast$line, " Unary: ", ast$operator, "\n")
    indent <- paste0(indent, "  ")
    print_ast(ast$obj, indent)
  } else if (inherits(ast, "NullaryNode")) {
    cat(indent, ast$line, " Nullary: ", ast$operator, "\n")
  } else if (inherits(ast, "IfNode")) {
    cat(indent, ast$line, " If:\n")
    indent <- paste0(indent, "  ")
    cat(indent, "Condition:\n")
    print_ast(ast$condition, paste0(indent, "  "))
    cat(indent, "True Branch:\n")
    print_ast(ast$true_node, paste0(indent, "  "))
    cat(indent, "False Branch:\n")
    print_ast(ast$false_node, paste0(indent, "  "))
  } else if (inherits(ast, "BlockNode")) {
    cat(indent, "Block:\n")
    indent <- paste0(indent, "  ")
    lapply(ast$block, function(line) {
      print_ast(line, indent)
    })
  } else {
    cat(indent, "Symbol: ", ast, "\n")
  }
}
