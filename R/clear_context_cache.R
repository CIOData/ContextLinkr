#' Clear cached ContextLinkr context files
#'
#' `clear_context_cache()` removes cached Cancer InFocus context files from the
#' local ContextLinkr cache directory.
#'
#' @param confirm Logical. Must be `TRUE` to clear the cache.
#'
#' @return A tibble with cache directory, number of files removed, and whether
#'   the cache directory exists after clearing.
#'
#' @examples
#' \dontrun{
#' clear_context_cache(confirm = TRUE)
#' }
#'
#' @seealso [context_cache_info()]
#'
#' @export
clear_context_cache <- function(confirm = FALSE) {
    if (!is.logical(confirm) || length(confirm) != 1 || is.na(confirm)) {
        rlang::abort("`confirm` must be a single non-missing logical value.")
    }

    if (!confirm) {
        rlang::abort("Set `confirm = TRUE` to clear the ContextLinkr cache.")
    }

    cache_dir <- tools::R_user_dir(
        "ContextLinkr",
        which = "cache"
    )

    if (!dir.exists(cache_dir)) {
        return(
            tibble::tibble(
                cache_dir = cache_dir,
                files_removed = 0L,
                cache_exists = FALSE
            )
        )
    }

    cache_files <- list.files(
        cache_dir,
        full.names = TRUE,
        recursive = TRUE
    )

    files_removed <- length(cache_files)

    unlink(
        cache_files,
        recursive = TRUE,
        force = TRUE
    )

    tibble::tibble(
        cache_dir = cache_dir,
        files_removed = files_removed,
        cache_exists = dir.exists(cache_dir)
    )
}
