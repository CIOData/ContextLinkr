validate_context_request <- function(
        geographies,
        measures = NULL,
        geography = "tract",
        year = NULL,
        use_cache = TRUE
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

    if (!is.logical(use_cache) || length(use_cache) != 1 || is.na(use_cache)) {
        rlang::abort("`use_cache` must be a single non-missing logical value.")
    }

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
            geography = geography,
            use_cache = use_cache
        )

        unknown_measures <- setdiff(
            measures,
            available_measures$def
        )

        if (length(unknown_measures) > 0) {
            suggestions <- closest_context_measures(
                unknown_measures[[1]],
                available_measures
            )

            rlang::abort(
                paste(
                    paste0(
                        "`measures` contains unsupported value(s): ",
                        paste(unknown_measures, collapse = ", "),
                        "."
                    ),
                    format_context_measure_suggestions(suggestions)
                )
            )
        }
    }

    if (!is.null(year)) {
        validate_year(year)
    }

    invisible(TRUE)
}
