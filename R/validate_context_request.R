validate_context_request <- function(
        geographies,
        measures = NULL,
        geography = "tract",
        year = NULL
) {
    if (missing(geographies)) {
        rlang::abort("`geographies` is required.")
    }

    if (!is.character(geographies)) {
        rlang::abort("`geographies` must be a character vector.")
    }

    if (length(geographies) == 0) {
        rlang::abort("`geographies` must contain at least one value.")
    }

    if (anyNA(geographies)) {
        rlang::abort("`geographies` must not contain missing values.")
    }

    if (any(geographies == "")) {
        rlang::abort("`geographies` must not contain empty strings.")
    }

    validate_context_geography(geography)

    if (!is.null(measures)) {
        if (!is.character(measures)) {
            rlang::abort("`measures` must be `NULL` or a character vector.")
        }

        if (length(measures) == 0) {
            rlang::abort("`measures` must be `NULL` or contain at least one value.")
        }

        if (anyNA(measures)) {
            rlang::abort("`measures` must not contain missing values.")
        }

        if (any(measures == "")) {
            rlang::abort("`measures` must not contain empty strings.")
        }

        available_measures <- available_context_measures(
            geography = geography
        )

        unknown_measures <- setdiff(
            measures,
            available_measures$def
        )

        if (length(unknown_measures) > 0) {
            rlang::abort(
                paste0(
                    "`measures` contains unsupported value(s): ",
                    paste(unknown_measures, collapse = ", "),
                    "."
                )
            )
        }
    }

    if (!is.null(year)) {
        validate_year(year)
    }

    invisible(TRUE)
}
