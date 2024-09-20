# Function returning list of allowed functions
permittted_functions <- function() {
  c(
    "if", "{", "+", "-", "*",
    "/", "!", "&&", "||", "<-",
    "=", "("
  )
}

# Function to check if the given function is allowed
check_function <- function(fct) {
  fct %in% permittted_functions()
}

# Helper function to increment line number
increment_line <- function(env) {
  env$line <- env$line + 1
}

# Function to combine strings
combine_strings <- function(string_list) {
  paste0(string_list, collapse = "\n")
}

# Function to throw error
check_expr <- function(expr, message = "Error", check = TRUE) {
  if (!check) {
    if (!expr) {
      return(message)
    }
  }
  if (!expr) {
    stop(message)
  }
  return("")
}
