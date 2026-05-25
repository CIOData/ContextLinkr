#' Summarize linked geographic context results
#'
#' `link_summary()` returns a one-row summary of results from [link_context()],
#' including geocoding performance when geocoding was used and tract
#' identification performance when tract lookup was performed.
#'
#' @param .data A data frame returned by [link_context()] or another
#'   ContextLinkr workflow containing `.geocoded` and/or `.tract_identified`.
#'
#' @return A one-row tibble with counts and rates for geocoding and tract
#'   identification.
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

    if (!has_geocode && !has_tract) {
        rlang::abort(
            paste(
                "`link_summary()` requires `.geocoded` and/or",
                "`.tract_identified` columns."
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
