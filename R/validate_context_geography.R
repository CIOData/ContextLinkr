validate_context_geography <- function(geography) {
    if (!is.character(geography) || length(geography) != 1 || is.na(geography)) {
        rlang::abort("`geography` must be a single non-missing character string.")
    }

    if (!geography %in% c("county", "tract")) {
        rlang::abort("`geography` must be one of \"county\" or \"tract\".")
    }

    invisible(TRUE)
}
