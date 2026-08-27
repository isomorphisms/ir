# A deliberately small S4 corpus whose observable behavior can be compared
# with translated IR code. Keep names unique so the fixture can coexist with
# ordinary packages in a clean R session.

setClass(
  "MassacrePoint",
  slots = c(x = "numeric", y = "numeric"),
  prototype = list(x = 0, y = 0),
  validity = function(object) {
    if (length(object@x) != 1L || length(object@y) != 1L) {
      return("x and y must each have length one")
    }
    if (!is.finite(object@x) || !is.finite(object@y)) {
      return("x and y must be finite")
    }
    TRUE
  }
)

setClass(
  "MassacreNamedPoint",
  contains = "MassacrePoint",
  slots = c(name = "character"),
  prototype = list(name = "unnamed"),
  validity = function(object) {
    if (length(object@name) != 1L || !nzchar(object@name)) {
      return("name must be one non-empty string")
    }
    TRUE
  }
)

setGeneric(
  "massacre_norm",
  function(x) standardGeneric("massacre_norm")
)

setMethod(
  "massacre_norm",
  "MassacrePoint",
  function(x) sqrt(x@x^2 + x@y^2)
)

setGeneric(
  "massacre_describe",
  function(x) standardGeneric("massacre_describe")
)

setMethod(
  "massacre_describe",
  "MassacrePoint",
  function(x) sprintf("point(%s, %s)", x@x, x@y)
)

setMethod(
  "massacre_describe",
  "MassacreNamedPoint",
  function(x) sprintf("%s=(%s, %s)", x@name, x@x, x@y)
)

setGeneric(
  "massacre_pair",
  function(left, right) standardGeneric("massacre_pair")
)

setMethod(
  "massacre_pair",
  signature(left = "MassacrePoint", right = "MassacrePoint"),
  function(left, right) "point-point"
)

setMethod(
  "massacre_pair",
  signature(left = "MassacreNamedPoint", right = "MassacrePoint"),
  function(left, right) "named-point"
)

setAs(
  "MassacrePoint",
  "numeric",
  function(from) c(x = from@x, y = from@y)
)
