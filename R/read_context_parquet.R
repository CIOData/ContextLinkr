#' Read a Cancer InFocus context Parquet file
#'
#' Reads a local or remote Cancer InFocus Parquet file and converts low-level
#' read failures into user-facing ContextLinkr errors. Remote files can be
#' cached locally to reduce repeated downloads.
#'
#' @param path Local path or URL to a Parquet file.
#' @param use_cache Logical. If `TRUE`, remote files are cached locally before
#'   reading.
#' @param refresh_cache Logical. If `TRUE`, remote files are downloaded again
#'   even when a cached copy exists. Ignored when `use_cache = FALSE`.
#'
#' @return A tibble containing the Parquet data.
#'
#' @keywords internal
read_context_parquet <- function(path, use_cache = TRUE, refresh_cache = FALSE) {
    if (!is.character(path) || length(path) != 1 || is.na(path)) {
        rlang::abort("`path` must be a single non-missing character string.")
    }

    if (path == "") {
        rlang::abort("`path` must not be an empty string.")
    }

    if (!is.logical(use_cache) || length(use_cache) != 1 || is.na(use_cache)) {
        rlang::abort("`use_cache` must be a single non-missing logical value.")
    }

    if (!is.logical(refresh_cache) || length(refresh_cache) != 1 || is.na(refresh_cache)) {
        rlang::abort("`refresh_cache` must be a single non-missing logical value.")
    }

    read_path <- path

    if (use_cache && is_remote_path(path)) {
        cache_path <- context_cache_path(path)

        if (refresh_cache || !file.exists(cache_path)) {
            tryCatch(
                utils::download.file(
                    url = path,
                    destfile = cache_path,
                    mode = "wb",
                    quiet = TRUE
                ),
                error = function(cnd) {
                    rlang::abort(
                        paste(
                            "Cancer InFocus context data could not be downloaded.",
                            "Check your internet connection and confirm that the",
                            "hosted ContextLinkr data files are available."
                        ),
                        parent = cnd
                    )
                },
                warning = function(cnd) {
                    rlang::abort(
                        paste(
                            "Cancer InFocus context data could not be downloaded.",
                            "Check your internet connection and confirm that the",
                            "hosted ContextLinkr data files are available."
                        ),
                        parent = cnd
                    )
                }
            )
        }

        read_path <- cache_path
    }

    tryCatch(
        tibble::as_tibble(
            arrow::read_parquet(read_path)
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
