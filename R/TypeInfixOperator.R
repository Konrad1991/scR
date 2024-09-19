`%type%` <- function(variable, type) {
  print(type)
  attr(variable, "type") <- type
}
