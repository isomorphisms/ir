args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) {
  stop("usage: Rscript extract_contract.R path/to/file.R", call. = FALSE)
}

source_path <- args[[1L]]
parsed <- parse(source_path, keep.source = TRUE)

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

argument <- function(expr, name, position = NULL) {
  values <- as.list(expr[-1L])
  names_ <- names(values)

  if (!is.null(names_) && name %in% names_) {
    return(values[[which(names_ == name)[1L]]])
  }

  if (!is.null(position) && length(values) >= position) {
    return(values[[position]])
  }

  NULL
}

literal_string <- function(expr) {
  if (is.character(expr) && length(expr) == 1L) {
    return(expr)
  }
  NULL
}

literal_string_vector <- function(expr) {
  one <- literal_string(expr)
  if (!is.null(one)) {
    return(one)
  }

  if (!is.call(expr) || call_name(expr) != "c") {
    return(NULL)
  }

  values <- as.list(expr[-1L])
  if (!all(vapply(values, function(x) is.character(x) && length(x) == 1L, logical(1)))) {
    return(NULL)
  }

  unname(unlist(values, use.names = FALSE))
}

literal_named_strings <- function(expr) {
  if (!is.call(expr) || !(call_name(expr) %in% c("c", "list", "signature"))) {
    return(NULL)
  }

  values <- as.list(expr[-1L])
  names_ <- names(values)
  if (is.null(names_) || any(!nzchar(names_))) {
    return(NULL)
  }
  if (!all(vapply(values, function(x) is.character(x) && length(x) == 1L, logical(1)))) {
    return(NULL)
  }

  stats::setNames(unname(unlist(values, use.names = FALSE)), names_)
}

record_call <- function(expr, expression_number, path) {
  feature <- call_name(expr)
  raw <- paste(deparse(expr, width.cutoff = 120L), collapse = " ")

  if (identical(feature, "setClass")) {
    name <- literal_string(argument(expr, "Class", 1L))
    slots <- literal_named_strings(argument(expr, "slots", 2L))
    contains <- literal_string_vector(argument(expr, "contains"))
    return(list(
      kind = "class",
      expression = expression_number,
      path = path,
      supported = !is.null(name) && !is.null(slots),
      name = name,
      slots = slots,
      contains = contains,
      raw = raw
    ))
  }

  if (identical(feature, "setGeneric")) {
    name <- literal_string(argument(expr, "name", 1L))
    return(list(
      kind = "generic",
      expression = expression_number,
      path = path,
      supported = !is.null(name),
      name = name,
      raw = raw
    ))
  }

  if (identical(feature, "setMethod")) {
    generic <- literal_string(argument(expr, "f", 1L))
    signature_expr <- argument(expr, "signature", 2L)
    signature <- literal_named_strings(signature_expr)
    if (is.null(signature)) {
      one <- literal_string(signature_expr)
      if (!is.null(one)) {
        signature <- c(.first = one)
      }
    }
    return(list(
      kind = "method",
      expression = expression_number,
      path = path,
      supported = !is.null(generic) && !is.null(signature),
      generic = generic,
      signature = signature,
      raw = raw
    ))
  }

  if (identical(feature, "setAs")) {
    from <- literal_string(argument(expr, "from", 1L))
    to <- literal_string(argument(expr, "to", 2L))
    return(list(
      kind = "coercion",
      expression = expression_number,
      path = path,
      supported = !is.null(from) && !is.null(to),
      from = from,
      to = to,
      raw = raw
    ))
  }

  NULL
}

entries <- list()
entry_number <- 0L
interesting <- c("setClass", "setGeneric", "setMethod", "setAs")

walk <- function(expr, expression_number, path = "root") {
  if (!is.call(expr) && !is.pairlist(expr) && !is.expression(expr)) {
    return(invisible(NULL))
  }

  if (is.call(expr) && call_name(expr) %in% interesting) {
    entry <- record_call(expr, expression_number, path)
    if (!is.null(entry)) {
      entry_number <<- entry_number + 1L
      entries[[entry_number]] <<- entry
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

contract <- list(
  source = normalizePath(source_path, mustWork = FALSE),
  entries = entries,
  note = paste(
    "This is a conservative first-stage migration contract.",
    "supported = FALSE means the declaration was too dynamic to extract safely."
  )
)

dput(contract)
