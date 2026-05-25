#' Filter successfully linked records
#'
#' `link_successes()` returns rows that were successfully linked to Census
#' tract geography. For results from [link_context()], this means
#' `.tract_identified` is `TRUE`.
#'
#' @param .data A data frame returned by [link_context()] or another
#'   ContextLinkr workflow containing `.tract_identified`.
#'
#' @return A tibble containing rows where `.tract_identified` is `TRUE`.
#'
#' @examples
#' linked <- tibble::tibble(
#'   id = 1:3,
#'   .tract_identified = c(TRUE, FALSE, TRUE)
#' )
#'
#' link_successes(linked)
#'
#' @seealso [link_context()], [link_summary()], [link_failures()]
#'
#' @export
link_successes <- function(.data) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!".tract_identified" %in% names(.data)) {
        rlang::abort("`.data` must contain a `.tract_identified` column.")
    }

    keep <- !is.na(.data[[".tract_identified"]]) &
        .data[[".tract_identified"]] == TRUE

    tibble::as_tibble(.data[keep, , drop = FALSE])
}

#' Filter records that were not successfully linked
#'
#' `link_failures()` returns rows that were not successfully linked to Census
#' tract geography. For results from [link_context()], this means
#' `.tract_identified` is `FALSE` or missing.
#'
#' @param .data A data frame returned by [link_context()] or another
#'   ContextLinkr workflow containing `.tract_identified`.
#'
#' @return A tibble containing rows where `.tract_identified` is not `TRUE`.
#'
#' @examples
#' linked <- tibble::tibble(
#'   id = 1:3,
#'   .tract_identified = c(TRUE, FALSE, NA)
#' )
#'
#' link_failures(linked)
#'
#' @seealso [link_context()], [link_summary()], [link_successes()]
#'
#' @export
link_failures <- function(.data) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!".tract_identified" %in% names(.data)) {
        rlang::abort("`.data` must contain a `.tract_identified` column.")
    }

    keep <- is.na(.data[[".tract_identified"]]) |
        .data[[".tract_identified"]] != TRUE

    tibble::as_tibble(.data[keep, , drop = FALSE])
}
