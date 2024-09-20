# Node class
Node <- R6::R6Class(
  "Node",
  public = list(root = "root")
)

# Define the BinaryNode
BinaryNode <- R6::R6Class(
  "BinaryNode",
  inherit = Node,
  public = list(
    operator = NULL,
    left_node = NULL,
    right_node = NULL,
    line = NULL,
    error = NULL,
    initialize = function() {},
    string_left = function() {
      if (inherits(self$left_node, "R6")) {
        return(self$left_node$stringify())
      }
      return(self$left_node)
    },
    string_right = function() {
      if (inherits(self$right_node, "R6")) {
        return(self$right_node$stringify())
      }
      return(self$right_node)
    },
    stringify = function(indent = "") {
      # TODO: some functions need paranetheses
      # e.g. foo(a, b)
      if (self$error != "") {
        return(paste0(
          indent,
          self$string_left(),
          " ",
          self$operator, " ",
          self$string_right(),
          " # ", self$error, "\n"
        ))
      }
      return(
        paste0(
          indent,
          self$string_left(),
          " ",
          self$operator, " ",
          self$string_right(),
          ""
        )
      )
    }
  )
)

# Define the UnaryNode class
UnaryNode <- R6::R6Class(
  "UnaryNode",
  inherit = Node,
  public = list(
    operator = NULL,
    obj = NULL,
    line = NULL,
    error = NULL,
    initialize = function() {},
    string_obj = function() {
      if (inherits(self$obj, "R6")) {
        return(self$obj$stringify())
      }
      return(self$obj)
    },
    stringify = function(indent = "") {
      # TODO: some functions need paranetheses
      # e.g. bar(a)
      if (self$error != "") {
        return(paste0(
          indent, self$operator, " ",
          self$string_obj(), "",
          " # ", self$error, "\n"
        ))
      }
      return(paste0(
        indent, self$operator, "",
        self$string_obj(), ""
      ))
    }
  )
)

# Define the NullaryNode class
NullaryNode <- R6::R6Class(
  "NullaryNode",
  inherit = Node,
  public = list(
    operator = NULL,
    line = NULL,
    error = NULL,
    initialize = function() {},
    stringify = function(indent = "") {
      if (self$error != "") {
        return(paste0(
          indent, self$operator, "()",
          " # ", self$error, "\n"
        ))
      }
      return(paste0(indent, self$operator, "()"))
    }
  )
)

# Define the IfNode class
IfNode <- R6::R6Class(
  "IfNode",
  inherit = Node,
  public = list(
    condition = NULL,
    true_node = NULL,
    false_node = NULL,
    line = NULL,
    error = NULL,
    initialize = function() {},
    string_condition = function(indent) {
      if (inherits(self$condition, "R6")) {
        return(self$condition$stringify(indent = paste0(indent, "")))
      }
      return(self$condition)
    },
    string_true = function(indent) {
      if (inherits(self$true_node, "R6")) {
        return(self$true_node$stringify(indent = paste0(indent, "  ")))
      }
      return(self$true_node)
    },
    string_false = function(indent) {
      if (inherits(self$false_node, "R6")) {
        return(self$false_node$stringify(indent = paste0(indent, "  ")))
      }
      return(self$false_node)
    },
    stringify = function(indent = "") {
      result <- NULL
      if (self$error != "") {
        result <- paste0(
          indent, "if (",
          self$string_condition(""),
          self$error,
          ") {\n"
        )
      } else {
        result <- paste0(
          indent, "if (",
          self$string_condition(""), ") {\n"
        )
      }
      result <- paste0(
        result,
        self$string_true(indent),
        "\n"
      )

      if (!is.null(self$false_node)) {
        result <- paste0(result, indent, "} else {\n")
        result <- paste0(
          result, self$false_node$stringify(
            indent = paste0(indent, "  ")
          ), "\n"
        )
      }
      result <- paste0(result, indent, "}")
      return(result)
    }
  )
)

# Define the BlockNode class
BlockNode <- R6::R6Class(
  "BlockNode",
  inherit = Node,
  public = list(
    block = NULL,
    line = NULL,
    error = NULL,
    initialize = function() {},
    stringify = function(indent = "") {
      result <- list()
      for (stmt in self$block) {
        if (inherits(stmt, "R6")) {
          result[[length(result) + 1]] <-
            stmt$stringify(indent = paste0(indent, ""))
          next
        } else {
          result[[length(result) + 1]] <- paste0(indent, stmt)
        }
      }
      result <- combine_strings(result)
      return(result)
    }
  )
)
