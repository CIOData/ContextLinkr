#' Read the ContextLinkr hosted data manifest
#'
#' Reads the hosted Cancer InFocus ContextLinkr data manifest.
#'
#' @param base_url Base URL for ContextLinkr public data files.
#'
#' @return A list containing manifest metadata.
#'
#' @keywords internal
read_context_manifest <- function(
        base_url = "https://cancerinfocus.org/public-data/ContextLinkr"
) {
    if (!is.character(base_url) || length(base_url) != 1 || is.na(base_url)) {
        rlang::abort("`base_url` must be a single non-missing character string.")
    }

    if (base_url == "") {
        rlang::abort("`base_url` must not be an empty string.")
    }

    base_url <- sub("/+$", "", base_url)
    manifest_url <- paste0(base_url, "/manifest.json")

    tryCatch(
        jsonlite::fromJSON(manifest_url, simplifyVector = FALSE),
        error = function(cnd) {
            rlang::abort(
                paste(
                    "Cancer InFocus context data manifest could not be read.",
                    "Check your internet connection and confirm that the",
                    "hosted ContextLinkr manifest is available."
                ),
                parent = cnd
            )
        }
    )
}
