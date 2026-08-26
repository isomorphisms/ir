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
    GENERIC     <- intToUtf8(0x2297) # ⊗

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
        identical(GENERIC, "⊗")
    )

    ## Unicode letters remain ordinary names.
    stopifnot(identical(parse1(PI), as.name("π")))

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

    ## Unreserved glyphs still use the broad generic infix path.  Define one
    ## as an ordinary function, then prove the same glyph parses and evaluates
    ## infix rather than being rejected merely because it is Unicode.
    syntaxEnv <- new.env(parent = baseenv())
    eval(parse1(paste0(GENERIC, " ", LEFT, " ", LAMBDA,
                       "(a, b) a + b")), syntaxEnv)
    genericCall <- parse1(paste("2", GENERIC, "3"))
    stopifnot(
        identical(as.character(genericCall[[1L]]), GENERIC),
        identical(eval(genericCall, syntaxEnv), 5)
    )
}
