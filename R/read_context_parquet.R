#' Read a Cancer InFocus context Parquet file
#'
#' Reads a local or remote Cancer InFocus Parquet file and converts low-level
#' read failures into user-facing ContextLinkr errors.
#'
#' @param path Local path or URL to a Parquet file.
#'
#' @return A tibble containing the Parquet data.
#'
#' @keywords internal
read_context_parquet <- function(path) {
    if (!is.character(path) || length(path) != 1 || is.na(path)) {
        rlang::abort("`path` must be a single non-missing character string.")
    }

    if (path == "") {
        rlang::abort("`path` must not be an empty string.")
    }

    tryCatch(
        tibble::as_tibble(
            arrow::read_parquet(path)
        ),
        error = function(cnd) {
            rlang::abort(
                paste(
                    "Cancer InFocus context data could not be read.",
                    "Check your internet connection and confirm that the",
                    "hosted ContextLinkr data files are available."
                ),
                parent = cnd
            )
        }
    )
}
