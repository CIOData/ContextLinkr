#' Report ContextLinkr hosted data sources
#'
#' `context_data_sources()` reports the hosted Cancer InFocus ContextLinkr data
#' source location and available manifest metadata.
#'
#' @param base_url Base URL for ContextLinkr public data files.
#'
#' @return A tibble with the base URL and available manifest metadata.
#'
#' @examples
#' \dontrun{
#' context_data_sources()
#' }
#'
#' @export
context_data_sources <- function(
        base_url = "https://cancerinfocus.org/public-data/ContextLinkr"
) {
    manifest <- read_context_manifest(base_url = base_url)

    names_manifest <- names(manifest)

    tibble::tibble(
        base_url = base_url,
        manifest_fields = paste(names_manifest, collapse = ", "),
        generated_at = manifest[["generated_at"]] %||% NA_character_,
        source = manifest[["source"]] %||% NA_character_,
        files = paste(unlist(manifest[["files"]] %||% character()), collapse = ", ")
    )
}
