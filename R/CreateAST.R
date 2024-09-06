walk <- function(code, fct, ...) {
  if (!is.call(code)) {
    return(code)
  }
  code <- as.list(code)
  fct(code, ...)
  lapply(code, \(x) walk(x, fct, ...))
}
