validate_context_format <- function(format) {
    if (!is.character(format) || length(format) != 1 || is.na(format)) {
        rlang::abort("`format` must be a single non-missing character string.")
    }

    if (!format %in% c("long", "wide")) {
        rlang::abort("`format` must be one of \"long\" or \"wide\".")
    }

    invisible(TRUE)
}
