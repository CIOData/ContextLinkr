#' Format Cancer InFocus measure suggestions
#'
#' Formats close Cancer InFocus measure matches for inclusion in an error
#' message.
#'
#' @param suggestions Character vector of suggested measure definitions.
#'
#' @return A single character string.
#'
#' @keywords internal
format_context_measure_suggestions <- function(suggestions) {
    if (!is.character(suggestions)) {
        rlang::abort("`suggestions` must be a character vector.")
    }

    suggestions <- unique(stats::na.omit(suggestions))
    suggestions <- suggestions[suggestions != ""]

    if (length(suggestions) == 0) {
        return(
            paste(
                "Use `available_context_measures()` or",
                "`search_context_measures()` to find valid measure definitions."
            )
        )
    }

    paste0(
        "Use `available_context_measures()` or `search_context_measures()` ",
        "to find valid measure definitions. Closest matches include: ",
        paste(suggestions, collapse = ", "),
        "."
    )
}
