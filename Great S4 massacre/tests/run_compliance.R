full_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", full_args, value = TRUE)

if (length(file_arg) == 1L) {
  script_path <- normalizePath(sub("^--file=", "", file_arg), mustWork = TRUE)
  massacre_root <- dirname(dirname(script_path))
} else {
  massacre_root <- normalizePath("Great S4 massacre", mustWork = TRUE)
}

source(file.path(massacre_root, "fixtures", "reference_s4.R"))

checks <- 0L

fail <- function(message) {
  stop(message, call. = FALSE)
}

expect_true <- function(value, label) {
  checks <<- checks + 1L
  if (!isTRUE(value)) {
    fail(paste0("FAIL: ", label))
  }
}

expect_equal <- function(actual, expected, label, tolerance = .Machine$double.eps^0.5) {
  checks <<- checks + 1L
  comparison <- all.equal(actual, expected, tolerance = tolerance, check.attributes = TRUE)
  if (!isTRUE(comparison)) {
    fail(paste0("FAIL: ", label, "\n", paste(comparison, collapse = "\n")))
  }
}

expect_error <- function(expr, label) {
  checks <<- checks + 1L
  errored <- FALSE
  tryCatch(
    force(expr),
    error = function(e) {
      errored <<- TRUE
      invisible(e)
    }
  )
  if (!errored) {
    fail(paste0("FAIL: expected an error: ", label))
  }
}

# Construction and prototypes.
default_point <- new("MassacrePoint")
expect_equal(default_point@x, 0, "point prototype supplies x")
expect_equal(default_point@y, 0, "point prototype supplies y")
expect_true(setequal(slotNames(default_point), c("x", "y")), "point exposes the declared slots")

point <- new("MassacrePoint", x = 3, y = 4)
expect_true(is(point, "MassacrePoint"), "constructed object has its class")
expect_equal(slot(point, "x"), 3, "slot() reads a slot")
expect_equal(point@y, 4, "@ reads a slot")

# Validity is a semantic obligation, not decoration.
expect_error(
  new("MassacrePoint", x = numeric(0), y = 1),
  "construction rejects a validity violation"
)
expect_error(
  new("MassacrePoint", x = Inf, y = 1),
  "construction rejects non-finite coordinates"
)

mutated <- point
mutated@x <- c(1, 2)
expect_error(validObject(mutated), "validObject sees a post-construction validity violation")

# Inheritance preserves substitutability and inherited defaults.
named <- new("MassacreNamedPoint", x = 6, y = 8, name = "home")
expect_true(is(named, "MassacreNamedPoint"), "subclass has its direct class")
expect_true(is(named, "MassacrePoint"), "subclass is also an instance of its parent")
expect_equal(new("MassacreNamedPoint")@x, 0, "subclass inherits the parent x prototype")
expect_equal(new("MassacreNamedPoint")@name, "unnamed", "subclass supplies its own prototype")
expect_error(
  new("MassacreNamedPoint", name = ""),
  "subclass validity is enforced"
)

# Generic dispatch chooses the method associated with runtime classes.
expect_equal(massacre_norm(point), 5, "single dispatch calls the point method")
expect_equal(massacre_norm(named), 10, "inherited method applies to the subclass")
expect_equal(
  massacre_describe(point),
  "point(3, 4)",
  "base-class method is selected for the base class"
)
expect_equal(
  massacre_describe(named),
  "home=(6, 8)",
  "more-specific subclass method overrides the base-class method"
)

# S4 can dispatch on more than one argument; preserve the observable choice.
expect_equal(
  massacre_pair(point, point),
  "point-point",
  "multiple dispatch matches the base/base signature"
)
expect_equal(
  massacre_pair(named, point),
  "named-point",
  "multiple dispatch prefers the more-specific first argument"
)
expect_equal(
  massacre_pair(point, named),
  "point-point",
  "a subclass satisfies a parent position when no more-specific method exists"
)

# Explicit coercions are part of the contract too.
expect_equal(
  as(point, "numeric"),
  c(x = 3, y = 4),
  "registered coercion produces the declared representation"
)

cat(sprintf("Great S4 massacre: %d compliance checks passed.\n", checks))
