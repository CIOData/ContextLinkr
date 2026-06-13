#' Detect remote paths
#'
#' Detects whether a path is an HTTP or HTTPS URL.
#'
#' @param path Local path or URL.
#'
#' @return A logical value.
#'
#' @keywords internal
is_remote_path <- function(path) {
    if (!is.character(path) || length(path) != 1 || is.na(path)) {
        rlang::abort("`path` must be a single non-missing character string.")
    }

    grepl("^https?://", path)
}
