#' Filter records successfully joined to contextual data
#'
#' `context_successes()` returns rows that were successfully joined to
#' contextual data. For results from [join_context()], this means
#' `.context_joined` is `TRUE`.
#'
#' @param .data A data frame returned by [join_context()] or another
#'   ContextLinkr workflow containing `.context_joined`.
#'
#' @return A tibble containing rows where `.context_joined` is `TRUE`.
#'
#' @examples
#' joined <- tibble::tibble(
#'   id = 1:3,
#'   .context_joined = c(TRUE, FALSE, TRUE)
#' )
#'
#' context_successes(joined)
#'
#' @seealso [join_context()], [context_summary()], [link_summary()],
#'   [missing_context_keys()], [context_failures()]
#'
#' @export
context_successes <- function(.data) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!".context_joined" %in% names(.data)) {
        rlang::abort("`.data` must contain a `.context_joined` column.")
    }

    keep <- !is.na(.data[[".context_joined"]]) &
        .data[[".context_joined"]] == TRUE

    tibble::as_tibble(.data[keep, , drop = FALSE])
}

#' Filter records not successfully joined to contextual data
#'
#' `context_failures()` returns rows that were not successfully joined to
#' contextual data. For results from [join_context()], this means
#' `.context_joined` is `FALSE` or missing.
#'
#' @param .data A data frame returned by [join_context()] or another
#'   ContextLinkr workflow containing `.context_joined`.
#'
#' @return A tibble containing rows where `.context_joined` is not `TRUE`.
#'
#' @examples
#' joined <- tibble::tibble(
#'   id = 1:3,
#'   .context_joined = c(TRUE, FALSE, NA)
#' )
#'
#' context_failures(joined)
#'
#' @seealso [join_context()], [context_summary()], [link_summary()],
#'   [missing_context_keys()], [context_successes()]
#'
#' @export
context_failures <- function(.data) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!".context_joined" %in% names(.data)) {
        rlang::abort("`.data` must contain a `.context_joined` column.")
    }

    keep <- is.na(.data[[".context_joined"]]) |
        .data[[".context_joined"]] != TRUE

    tibble::as_tibble(.data[keep, , drop = FALSE])
}
