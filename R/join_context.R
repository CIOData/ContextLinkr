#' Join linked records to contextual data
#'
#' `join_context()` joins individual-level records that have been linked to
#' Census tract geography with a user-supplied contextual dataset.
#'
#' This function does not download contextual data. It is intended for workflows
#' where contextual variables are already available, including future Cancer
#' InFocus exports or other tract-level datasets.
#'
#' @param .data A data frame containing linked individual-level records.
#' @param context A data frame containing contextual variables.
#' @param by Character string giving the join key. Defaults to `"tract_geoid"`.
#' @param suffix Character vector of length 2 used to disambiguate duplicate
#'   non-key column names in `.data` and `context`.
#'
#' @return A tibble containing `.data` with matching contextual variables
#'   joined from `context`.
#'
#' @examples
#' linked <- tibble::tibble(
#'   id = 1:2,
#'   tract_geoid = c("11001980000", "24510040100")
#' )
#'
#' context <- tibble::tibble(
#'   tract_geoid = c("11001980000", "24510040100"),
#'   deprivation_index = c(0.8, 0.6)
#' )
#'
#' join_context(linked, context)
#'
#' @seealso [link_context()], [link_summary()], [link_successes()],
#'   [link_failures()]
#'
#' @export
join_context <- function(
        .data,
        context,
        by = "tract_geoid",
        suffix = c("", "_context")
) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!is.data.frame(context)) {
        rlang::abort("`context` must be a data frame.")
    }

    if (!is.character(by) || length(by) != 1 || is.na(by) || by == "") {
        rlang::abort("`by` must be a single non-missing character string.")
    }

    if (!by %in% names(.data)) {
        rlang::abort(paste0("`.data` must contain the join key `", by, "`."))
    }

    if (!by %in% names(context)) {
        rlang::abort(paste0("`context` must contain the join key `", by, "`."))
    }

    if (!is.character(suffix) || length(suffix) != 2 || anyNA(suffix)) {
        rlang::abort("`suffix` must be a character vector of length 2.")
    }

    data_key <- as.character(.data[[by]])
    context_key <- as.character(context[[by]])

    duplicate_context_keys <- unique(context_key[duplicated(context_key) & !is.na(context_key)])

    if (length(duplicate_context_keys) > 0) {
        rlang::abort(
            paste0(
                "`context` must contain no duplicate values in `",
                by,
                "`."
            )
        )
    }

    .data[[by]] <- data_key
    context[[by]] <- context_key

    joined <- merge(
        x = .data,
        y = context,
        by = by,
        all.x = TRUE,
        sort = FALSE,
        suffixes = suffix
    )

    tibble::as_tibble(joined)
}
