#' Find close Cancer InFocus measure matches
#'
#' Finds likely valid Cancer InFocus measure definitions for an unsupported
#' measure name.
#'
#' @param measure Unsupported measure name.
#' @param available_measures A data frame returned by [available_context_measures()].
#' @param n Maximum number of close matches to return.
#'
#' @return A character vector of suggested measure definitions.
#'
#' @keywords internal
closest_context_measures <- function(
        measure,
        available_measures,
        n = 5
) {
    if (!is.character(measure) || length(measure) != 1 || is.na(measure)) {
        rlang::abort("`measure` must be a single non-missing character string.")
    }

    if (measure == "") {
        rlang::abort("`measure` must not be an empty string.")
    }

    if (!is.data.frame(available_measures)) {
        rlang::abort("`available_measures` must be a data frame.")
    }

    if (!"def" %in% names(available_measures)) {
        rlang::abort("`available_measures` must contain a `def` column.")
    }

    if (!is.numeric(n) || length(n) != 1 || is.na(n) || n < 1) {
        rlang::abort("`n` must be a single number greater than or equal to 1.")
    }

    defs <- unique(stats::na.omit(as.character(available_measures$def)))

    if (length(defs) == 0) {
        return(character())
    }

    distances <- utils::adist(
        tolower(measure),
        tolower(defs)
    )

    defs[order(as.numeric(distances))][seq_len(min(n, length(defs)))]
}
