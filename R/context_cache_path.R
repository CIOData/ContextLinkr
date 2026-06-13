#' Create a cache path for Cancer InFocus context files
#'
#' Creates a stable local cache path for a hosted Cancer InFocus ContextLinkr
#' data URL.
#'
#' @param url URL for a hosted ContextLinkr data file.
#'
#' @return A character string containing the local cache path.
#'
#' @keywords internal
context_cache_path <- function(url) {
    if (!is.character(url) || length(url) != 1 || is.na(url)) {
        rlang::abort("`url` must be a single non-missing character string.")
    }

    if (url == "") {
        rlang::abort("`url` must not be an empty string.")
    }

    cache_dir <- tools::R_user_dir(
        "ContextLinkr",
        which = "cache"
    )

    dir.create(
        cache_dir,
        recursive = TRUE,
        showWarnings = FALSE
    )

    file_name <- gsub(
        "[^A-Za-z0-9._-]+",
        "_",
        url
    )

    file.path(cache_dir, file_name)
}
