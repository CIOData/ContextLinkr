#' Identify linked keys missing from contextual data
#'
#' `missing_context_keys()` returns the unique non-missing join keys from
#' linked individual-level records that are not present in a contextual dataset.
#'
#' This is useful before or after using [join_context()] to identify geographic
#' units that need contextual data.
#'
#' @param .data A data frame containing linked individual-level records.
#' @param context A data frame containing contextual variables.
#' @param by Join key specification. A single character string compares columns
#'   with the same name in `.data` and `context`. A named character vector of
#'   length one compares different column names, where the name is the column in
#'   `.data` and the value is the column in `context`, for example
#'   `c("tract_geoid" = "GEOID")`.
#'
#' @return A tibble with one column containing unique keys from `.data` that are
#'   not present in `context`.
#'
#' @examples
#' linked <- tibble::tibble(
#'   id = 1:3,
#'   tract_geoid = c("11001980000", "24510040100", "99999999999")
#' )
#'
#' context <- tibble::tibble(
#'   tract_geoid = c("11001980000", "24510040100"),
#'   deprivation_index = c(0.8, 0.6)
#' )
#'
#' missing_context_keys(linked, context)
#'
#' @seealso [join_context()], [context_failures()], [context_summary()]
#'
#' @export
missing_context_keys <- function(
        .data,
        context,
        by = "tract_geoid"
) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!is.data.frame(context)) {
        rlang::abort("`context` must be a data frame.")
    }

    join_by <- parse_join_by(by)
    data_by <- join_by$data_by
    context_by <- join_by$context_by

    if (!data_by %in% names(.data)) {
        rlang::abort(paste0("`.data` must contain the join key `", data_by, "`."))
    }

    if (!context_by %in% names(context)) {
        rlang::abort(
            paste0("`context` must contain the join key `", context_by, "`.")
        )
    }

    data_keys <- unique(stats::na.omit(as.character(.data[[data_by]])))
    context_keys <- unique(stats::na.omit(as.character(context[[context_by]])))

    missing_keys <- sort(setdiff(data_keys, context_keys))

    result <- tibble::tibble(missing_keys)
    names(result) <- data_by

    result
}
