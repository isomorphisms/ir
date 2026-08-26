## IR compatibility smoke: bare fn must remain ordinary R syntax.

parse1 <- function(text) parse(text = text, keep.source = FALSE)[[1L]]

## Regression for the shape used by rlang: fn is a formal and is assigned to.
stopifnot(identical(parse1("fn"), as.name("fn")))
call_trace_context <- eval(parse1(
    "function(call, fn) {
        fn <- fn
        fn
    }"
))
stopifnot(
    identical(names(formals(call_trace_context)), c("call", "fn")),
    identical(call_trace_context(NULL, 7L), 7L)
)

## The IR constructor spellings remain distinctive syntax.
lambda_identity <- eval(parse1("λ(fn) fn"))
florin_identity <- eval(parse1("ƒ(fn) fn"))
stopifnot(
    identical(lambda_identity(11L), 11L),
    identical(florin_identity(12L), 12L)
)

## Upstream packages are the oracle: do not patch or translate them.
compat_lib <- Sys.getenv("IR_COMPAT_LIB", "build/compat-lib")
.libPaths(c(compat_lib, .libPaths()))

packages <- c("rlang", "testthat", "tibble", "dplyr")
for (package in packages) {
    suppressPackageStartupMessages(
        library(package, character.only = TRUE)
    )
}

testthat::test_that("IR spellings work inside upstream testthat", {
    answer ← 8 ÷ 2
    testthat::expect_true(answer ≟ 4)
})
