#' Summarize linked geographic context results
#'
#' `link_summary()` returns a one-row summary of ContextLinkr workflow results,
#' including geocoding performance, tract identification performance, and
#' contextual data join performance when those metadata columns are present.
#'
#' @param .data A data frame returned by [link_context()] or another
#'   ContextLinkr workflow containing `.geocoded` and/or `.tract_identified`.
#'
#' @return A one-row tibble with counts and rates for geocoding, tract
#'   identification, and contextual data joins when available.
#'
#' @seealso [link_context()], [join_context()], [link_successes()],
#'   [link_failures()], [context_successes()], [context_failures()]
#'
#' @examples
#' linked <- tibble::tibble(
#'   id = 1:2,
#'   .geocoded = c(TRUE, FALSE),
#'   .tract_identified = c(TRUE, FALSE),
#'   .tract_state_fips = c("11", NA),
#'   .tract_year = c(2023, 2023)
#' )
#'
#' link_summary(linked)
#'
#' @export
link_summary <- function(.data) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    has_geocode <- ".geocoded" %in% names(.data)
    has_tract <- ".tract_identified" %in% names(.data)
    has_context <- ".context_joined" %in% names(.data)

    if (!has_geocode && !has_tract && !has_context) {
        rlang::abort(
            paste(
                "`link_summary()` requires `.geocoded`, `.tract_identified`,",
                "and/or `.context_joined` columns."
            )
        )
    }

    total <- nrow(.data)

    geocoded <- if (has_geocode) {
        sum(.data[[".geocoded"]], na.rm = TRUE)
    } else {
        NA_integer_
    }

    geocode_rate <- if (has_geocode && total > 0) {
        geocoded / total
    } else {
        NA_real_
    }

    tract_identified <- if (has_tract) {
        sum(.data[[".tract_identified"]], na.rm = TRUE)
    } else {
        NA_integer_
    }

    tract_identification_rate <- if (has_tract && total > 0) {
        tract_identified / total
    } else {
        NA_real_
    }

    context_joined <- if (has_context) {
        sum(.data[[".context_joined"]], na.rm = TRUE)
    } else {
        NA_integer_
    }

    context_join_rate <- if (has_context && total > 0) {
        context_joined / total
    } else {
        NA_real_
    }

    state_fips <- if (".tract_state_fips" %in% names(.data)) {
        unique_values(.data[[".tract_state_fips"]])
    } else {
        NA_character_
    }

    year <- if (".tract_year" %in% names(.data)) {
        unique_values(.data[[".tract_year"]])
    } else {
        NA_character_
    }

    tibble::tibble(
        total = total,
        geocoded = geocoded,
        geocode_rate = geocode_rate,
        geocode_rate_pct = round(geocode_rate * 100, 1),
        tract_identified = tract_identified,
        tract_identification_rate = tract_identification_rate,
        tract_identification_rate_pct = round(tract_identification_rate * 100, 1),
        context_joined = context_joined,
        context_join_rate = context_join_rate,
        context_join_rate_pct = round(context_join_rate * 100, 1),
        state_fips = state_fips,
        year = year
    )
}

unique_values <- function(x) {
    x <- unique(stats::na.omit(x))

    if (length(x) == 0) {
        return(NA_character_)
    }

    paste(as.character(x), collapse = ", ")
}
