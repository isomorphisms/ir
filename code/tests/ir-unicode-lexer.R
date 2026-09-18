## IR Unicode lexer priority and code-point honesty.

UTF8 <- l10n_info()[["UTF-8"]]

if (!UTF8) {
    message("SKIPPED: IR Unicode lexer tests need a UTF-8 locale")
} else {
    parse1 <- function(text) parse(text = text, keep.source = FALSE)[[1L]]

    ## Keep the literal glyph beside every code point.  The assertions below
    ## make the comments executable documentation rather than trusting sight.
    PI          <- intToUtf8(0x03c0) # π
    LAMBDA      <- intToUtf8(0x03bb) # λ
    FLORIN      <- intToUtf8(0x0192) # ƒ
    LEFT        <- intToUtf8(0x2190) # ←
    SUPER_LEFT  <- intToUtf8(0x219e) # ↞
    RIGHT       <- intToUtf8(0x2192) # →
    SUPER_RIGHT <- intToUtf8(0x21a0) # ↠
    DIVIDE      <- intToUtf8(0x00f7) # ÷
    TIMES       <- intToUtf8(0x00d7) # ×
    COMPOSE     <- intToUtf8(0x2218) # ∘
    EQUALITY    <- intToUtf8(0x225f) # ≟
    INVERTED_Q  <- intToUtf8(0x00bf) # ¿
    TENSOR      <- intToUtf8(0x2297) # ⊗
    GENERIC     <- intToUtf8(0x2299) # ⊙

    stopifnot(
        identical(PI, "π"),
        identical(LAMBDA, "λ"),
        identical(FLORIN, "ƒ"),
        identical(LEFT, "←"),
        identical(SUPER_LEFT, "↞"),
        identical(RIGHT, "→"),
        identical(SUPER_RIGHT, "↠"),
        identical(DIVIDE, "÷"),
        identical(TIMES, "×"),
        identical(COMPOSE, "∘"),
        identical(EQUALITY, "≟"),
        identical(INVERTED_Q, "¿"),
        identical(TENSOR, "⊗"),
        identical(GENERIC, "⊙")
    )

    ## U+03C0 is not merely displayed as π here: make π a real function name
    ## in parsed source and call it, so the code point, printed glyph and lexer
    ## all have to agree.
    syntaxEnv <- new.env(parent = baseenv())
    stopifnot(identical(parse1(PI), as.name("π")))
    eval(parse1(paste0(PI, " ", LEFT, " ", LAMBDA, "(x) x + 1")),
         syntaxEnv)
    stopifnot(identical(eval(parse1(paste0(PI, "(2)")), syntaxEnv), 3))

    ## Reserved glyphs must be eaten by their explicit syntax before the
    ## generic Unicode infix fallback gets a chance to classify them.
    stopifnot(
        identical(parse1(paste("x", LEFT, "1L")), quote(x <- 1L)),
        identical(parse1(paste("x", SUPER_LEFT, "1L")), quote(x <<- 1L)),
        identical(parse1(paste("1L", RIGHT, "x")), quote(x <- 1L)),
        identical(parse1(paste("1L", SUPER_RIGHT, "x")), quote(x <<- 1L)),
        identical(parse1(paste("1", EQUALITY, "1")), quote(1 == 1)),
        identical(parse1("1 ?= 1"), quote(1 == 1)),
        identical(parse1("1 =? 1"), quote(1 == 1)),
        identical(parse1("1 ?=? 1"), quote(1 == 1)),
        identical(parse1(paste0("1 ", INVERTED_Q, "=? 1")), quote(1 == 1))
    )

    ## ⊗ is IR's Kronecker/tensor-product operator.  Exercise a real matrix
    ## product rather than treating the glyph as an arbitrary infix placeholder.
    A <- matrix(c(1, 2,
                  3, 4), nrow = 2, byrow = TRUE)
    B <- matrix(c(0, 5,
                  6, 7), nrow = 2, byrow = TRUE)
    expectedTensor <- matrix(c(0,  5,  0, 10,
                               6,  7, 12, 14,
                               0, 15,  0, 20,
                              18, 21, 24, 28),
                             nrow = 4, byrow = TRUE)
    tensorCall <- parse1(paste("A", TENSOR, "B"))
    assign("A", A, envir = syntaxEnv)
    assign("B", B, envir = syntaxEnv)
    stopifnot(
        identical(as.character(tensorCall[[1L]]), TENSOR),
        identical(eval(tensorCall, syntaxEnv), expectedTensor),
        identical(A ⊗ B, expectedTensor),
        identical(A ⊗ B, A %x% B),
        identical(A ⊗ B, kronecker(A, B))
    )

    ## Unreserved glyphs still use the broad generic infix path.  Keep that
    ## lexer test separate from ⊗ so the tensor glyph has mathematical meaning.
    eval(parse1(paste0(GENERIC, " ", LEFT, " ", LAMBDA,
                       "(a, b) a + b")), syntaxEnv)
    genericCall <- parse1(paste("2", GENERIC, "3"))
    stopifnot(
        identical(as.character(genericCall[[1L]]), GENERIC),
        identical(eval(genericCall, syntaxEnv), 5)
    )
}
