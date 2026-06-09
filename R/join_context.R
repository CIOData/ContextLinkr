#' Join linked records to contextual data
#'
#' `join_context()` joins individual-level records that have been linked to
#' Census tract geography with a user-supplied contextual dataset.
#'
#' This function does not download contextual data. It is intended for workflows
#' where contextual variables are already available, including future Cancer
#' InFocus exports or other tract-level datasets.
#'
#' Use [context_summary()] or [link_summary()] after joining to summarize how
#' many linked records matched contextual data.
#'
#' @param .data A data frame containing linked individual-level records.
#' @param context A data frame containing contextual variables.
#' @param by Join key specification. A single character string joins columns
#'   with the same name in `.data` and `context`. A named character vector of
#'   length one joins different column names, where the name is the column in
#'   `.data` and the value is the column in `context`, for example
#'   `c("tract_geoid" = "GEOID")`.
#' @param suffix Character vector of length 2 used to disambiguate duplicate
#'   non-key column names in `.data` and `context`.
#'
#' @return A tibble containing `.data` with matching contextual variables
#'   joined from `context` and a `.context_joined` column indicating whether
#'   each row matched a contextual record.
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
#' @seealso [link_context()], [link_summary()], [context_summary()],
#'   [missing_context_keys()], [context_successes()], [context_failures()]
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

    if (!is.character(suffix) || length(suffix) != 2 || anyNA(suffix)) {
        rlang::abort("`suffix` must be a character vector of length 2.")
    }

    if (".context_joined" %in% names(.data)) {
        rlang::abort("`.data` must not already contain `.context_joined`.")
    }

    data_key <- as.character(.data[[data_by]])
    context_key <- as.character(context[[context_by]])

    duplicate_context_keys <- unique(
        context_key[duplicated(context_key) & !is.na(context_key)]
    )

    if (length(duplicate_context_keys) > 0) {
        rlang::abort(
            paste0(
                "`context` must contain no duplicate values in `",
                context_by,
                "`."
            )
        )
    }

    context_non_key <- setdiff(names(context), context_by)

    if (length(context_non_key) == 0) {
        rlang::abort("`context` must contain at least one non-key column.")
    }

    duplicate_non_key <- intersect(names(.data), context_non_key)

    data_out <- .data

    if (length(duplicate_non_key) > 0 && suffix[[1]] != "") {
        data_names <- names(data_out)
        data_names[data_names %in% duplicate_non_key] <- paste0(
            data_names[data_names %in% duplicate_non_key],
            suffix[[1]]
        )
        names(data_out) <- data_names
    }

    context_out <- context[context_non_key]

    if (length(duplicate_non_key) > 0) {
        context_names <- names(context_out)
        context_names[context_names %in% duplicate_non_key] <- paste0(
            context_names[context_names %in% duplicate_non_key],
            suffix[[2]]
        )
        names(context_out) <- context_names
    }

    row_match <- match(data_key, context_key)

    joined_context <- context_out[row_match, , drop = FALSE]
    rownames(joined_context) <- NULL

    result <- cbind(
        data_out,
        tibble::as_tibble(joined_context)
    )

    result[[".context_joined"]] <- !is.na(row_match) & !is.na(data_key)

    tibble::as_tibble(result)
}

parse_join_by <- function(by) {
    if (!is.character(by) || length(by) != 1 || is.na(by)) {
        rlang::abort(
            paste(
                "`by` must be a single non-missing character string or a named",
                "character vector of length one."
            )
        )
    }

    by_names <- names(by)

    if (!is.null(by_names)) {
        data_by <- by_names[[1]]
        context_by <- unname(by)[[1]]
    } else {
        data_by <- by[[1]]
        context_by <- by[[1]]
    }

    if (
        is.na(data_by) || data_by == "" ||
        is.na(context_by) || context_by == ""
    ) {
        rlang::abort(
            paste(
                "`by` must specify non-empty join key names for both `.data`",
                "and `context`."
            )
        )
    }

    list(
        data_by = data_by,
        context_by = context_by
    )
}
