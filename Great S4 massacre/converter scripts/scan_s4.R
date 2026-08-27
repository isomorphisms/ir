args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("usage: Rscript scan_s4.R path/to/file.R", call. = FALSE)
}

source_path <- args[[1L]]
parsed <- parse(source_path, keep.source = TRUE)

s4_features <- c(
  "setClass",
  "setClassUnion",
  "setGeneric",
  "setMethod",
  "setReplaceMethod",
  "setValidity",
  "setAs",
  "new",
  "validObject",
  "slot",
  "slot<-",
  "@",
  "as",
  "is"
)

call_name <- function(expr) {
  if (!is.call(expr)) {
    return(NA_character_)
  }

  head <- expr[[1L]]
  if (is.symbol(head)) {
    return(as.character(head))
  }

  if (is.call(head) && length(head) == 3L) {
    operator <- as.character(head[[1L]])
    if (operator %in% c("::", ":::")) {
      return(as.character(head[[3L]]))
    }
  }

  NA_character_
}

rows <- list()
row_number <- 0L

walk <- function(expr, expression_number, path = "root") {
  if (!is.call(expr) && !is.pairlist(expr) && !is.expression(expr)) {
    return(invisible(NULL))
  }

  if (is.call(expr)) {
    feature <- call_name(expr)
    if (!is.na(feature) && feature %in% s4_features) {
      row_number <<- row_number + 1L
      rows[[row_number]] <<- data.frame(
        expression = expression_number,
        path = path,
        feature = feature,
        call = paste(deparse(expr, width.cutoff = 120L), collapse = " "),
        stringsAsFactors = FALSE
      )
    }
  }

  for (i in seq_along(expr)) {
    if (identical(expr[[i]], quote(expr = ))) {
      next
    }
    child <- expr[[i]]
    if (is.call(child) || is.pairlist(child) || is.expression(child)) {
      walk(child, expression_number, paste0(path, "/", i))
    }
  }

  invisible(NULL)
}

for (i in seq_along(parsed)) {
  walk(parsed[[i]], i)
}

if (length(rows) == 0L) {
  cat("expression\tpath\tfeature\tcall\n")
  quit(status = 0L)
}

result <- do.call(rbind, rows)
write.table(
  result,
  file = stdout(),
  sep = "\t",
  row.names = FALSE,
  col.names = TRUE,
  quote = TRUE
)
