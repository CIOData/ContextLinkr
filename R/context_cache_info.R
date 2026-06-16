#' Report ContextLinkr cache information
#'
#' `context_cache_info()` reports where ContextLinkr stores cached Cancer
#' InFocus context files and summarizes the number and total size of files in
#' the cache.
#'
#' @return A tibble with cache directory, file count, and total size in bytes.
#'
#' @examples
#' context_cache_info()
#'
#' @seealso [clear_context_cache()]
#'
#' @export
context_cache_info <- function() {
    cache_dir <- tools::R_user_dir(
        "ContextLinkr",
        which = "cache"
    )

    if (!dir.exists(cache_dir)) {
        return(
            tibble::tibble(
                cache_dir = cache_dir,
                files = 0L,
                size_bytes = 0
            )
        )
    }

    cache_files <- list.files(
        cache_dir,
        full.names = TRUE,
        recursive = TRUE
    )

    if (length(cache_files) == 0) {
        return(
            tibble::tibble(
                cache_dir = cache_dir,
                files = 0L,
                size_bytes = 0
            )
        )
    }

    file_info <- file.info(cache_files)

    tibble::tibble(
        cache_dir = cache_dir,
        files = length(cache_files),
        size_bytes = sum(file_info$size, na.rm = TRUE)
    )
}
