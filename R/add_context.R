#' Add Cancer InFocus contextual variables to linked records
#'
#' `add_context()` retrieves Cancer InFocus contextual variables for Census tract
#' GEOIDs in linked individual-level records and joins those variables back to
#' the records.
#'
#' This function is useful when records already contain Census tract GEOIDs, or
#' when users want to run geographic linkage and contextual enrichment as
#' separate steps.
#'
#' @param .data A data frame containing linked individual-level records.
#' @param tract_col Column containing Census tract GEOIDs. Supports quoted or
#'   unquoted column names. Defaults to `"tract_geoid"`.
#' @param measures Optional character vector of Cancer InFocus measure
#'   definitions to retrieve. If `NULL`, all available measures may be
#'   retrieved.
#' @param use_cache Logical. If `TRUE`, hosted Cancer InFocus context files are
#'   cached locally before reading.
#' @param refresh_cache Logical. If `TRUE`, hosted files are downloaded again
#'   even when cached copies exist. Ignored when `use_cache = FALSE`.
#'
#' @return A tibble containing `.data` with selected Cancer InFocus contextual
#'   variables and context-join metadata.
#'
#' @examples
#' \dontrun{
#' linked <- link_context(
#'   sample_addresses,
#'   address = address,
#'   state = "DC",
#'   geocoder = "census_single",
#'   confirm_external = TRUE
#' )
#'
#' add_context(
#'   linked,
#'   tract_col = tract_geoid,
#'   measures = "Total Population"
#' )
#' }
#'
#' @seealso [link_context()], [get_context()], [join_context()]
#'
#' @export
add_context <- function(
        .data,
        tract_col = "tract_geoid",
        measures = NULL,
        use_cache = TRUE,
        refresh_cache = FALSE
) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!is.logical(use_cache) || length(use_cache) != 1 || is.na(use_cache)) {
        rlang::abort("`use_cache` must be a single non-missing logical value.")
    }

    if (!is.logical(refresh_cache) || length(refresh_cache) != 1 || is.na(refresh_cache)) {
        rlang::abort("`refresh_cache` must be a single non-missing logical value.")
    }

    tract_nm <- col_arg_name(rlang::enquo(tract_col))

    if (is.null(tract_nm)) {
        rlang::abort("`tract_col` must identify a column in `.data`.")
    }

    if (!tract_nm %in% names(.data)) {
        rlang::abort(
            paste0("`.data` must contain the tract column `", tract_nm, "`.")
        )
    }

    tract_ids <- unique(as.character(.data[[tract_nm]]))
    tract_ids <- tract_ids[!is.na(tract_ids) & tract_ids != ""]

    if (length(tract_ids) == 0) {
        result <- tibble::as_tibble(.data)

        result$.context_joined <- FALSE

        attr(result, "contextlinkr_context_summary") <- list(
            joined = 0L,
            total = nrow(result),
            join_rate = if (nrow(result) > 0) 0 else NA_real_,
            by = tract_nm
        )

        return(result)
    }

    context_data <- get_context(
        geographies = tract_ids,
        measures = measures,
        geography = "tract",
        format = "wide",
        use_cache = use_cache,
        refresh_cache = refresh_cache
    )

    names(context_data)[names(context_data) == "GEOID"] <- tract_nm

    join_context(
        .data,
        context_data,
        by = tract_nm
    )
}
