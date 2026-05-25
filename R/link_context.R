#' Link individual records to Census tract geography
#'
#' `link_context()` is an end-to-end convenience wrapper for linking
#' individual-level records to Census tract geography. It can either use
#' existing latitude/longitude columns or geocode address fields before
#' identifying Census tracts.
#'
#' This function does not currently download or join contextual variables.
#' It returns the input data with geocoding metadata, when geocoding is used,
#' and tract identification fields from [id_tract()].
#'
#' Use [link_summary()] to summarize geocoding and tract-identification
#' performance after linking records.
#'
#' @param .data A data frame containing individual-level records.
#' @param address Optional full address column. Supports quoted or unquoted
#'   column names.
#' @param street Optional street address column. Supports quoted or unquoted
#'   column names.
#' @param city Optional city column. Supports quoted or unquoted column names.
#' @param state_col Optional state column for component address geocoding.
#'   Supports quoted or unquoted column names.
#' @param zip Optional ZIP code column. Supports quoted or unquoted column names.
#' @param lat Optional latitude column. If both `lat` and `lon` are supplied,
#'   geocoding is skipped.
#' @param lon Optional longitude column. If both `lat` and `lon` are supplied,
#'   geocoding is skipped.
#' @param state State abbreviation, state FIPS code, or vector of states used
#'   for Census tract lookup. Passed to [id_tract()].
#' @param geocoder Geocoder passed to [gc_address()] when geocoding is needed.
#' @param confirm_external Logical. Must be `TRUE` before address data are sent
#'   to an external geocoding service.
#' @param year Census tract boundary year passed to [id_tract()].
#' @param keep_geometry Logical. Whether to keep tract geometry in the output.
#'   Passed to [id_tract()].
#' @param cache Logical. Whether to use tigris caching during tract lookup.
#'   Passed to [id_tract()].
#'
#' @return A data frame containing the original records plus geocoding and/or
#'   Census tract fields.
#'
#' @seealso [gc_address()], [id_tract()], [link_summary()]
#'
#' @examples
#' \dontrun{
#' link_context(
#'   sample_addresses,
#'   address = address,
#'   state = "DC",
#'   geocoder = "census_single",
#'   confirm_external = TRUE
#' )
#'
#' link_context(
#'   geocoded_data,
#'   lat = latitude,
#'   lon = longitude,
#'   state = c("DC", "MD")
#' )
#' }
#'
#' @export
link_context <- function(
        .data,
        address = NULL,
        street = NULL,
        city = NULL,
        state_col = NULL,
        zip = NULL,
        lat = NULL,
        lon = NULL,
        state,
        geocoder = c("census_batch", "census_single", "osm"),
        confirm_external = FALSE,
        year = 2023,
        keep_geometry = FALSE,
        cache = TRUE
) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (missing(state) || is.null(state)) {
        rlang::abort("`state` is required for tract lookup.")
    }

    geocoder <- match.arg(geocoder)

    lat_nm <- col_arg_name(rlang::enquo(lat))
    lon_nm <- col_arg_name(rlang::enquo(lon))

    has_lat <- !is.null(lat_nm)
    has_lon <- !is.null(lon_nm)

    if (xor(has_lat, has_lon)) {
        rlang::abort("Both `lat` and `lon` must be supplied together.")
    }

    if (has_lat && has_lon) {
        return(
            do.call(
                id_tract,
                list(
                    .data = .data,
                    lat = lat_nm,
                    lon = lon_nm,
                    state = state,
                    year = year,
                    keep_geometry = keep_geometry,
                    cache = cache
                )
            )
        )
    }

    address_nm <- col_arg_name(rlang::enquo(address))
    street_nm <- col_arg_name(rlang::enquo(street))
    city_nm <- col_arg_name(rlang::enquo(city))
    state_col_nm <- col_arg_name(rlang::enquo(state_col))
    zip_nm <- col_arg_name(rlang::enquo(zip))

    has_full_address <- !is.null(address_nm)

    has_component_address <- all(
        !vapply(
            list(street_nm, city_nm, state_col_nm, zip_nm),
            is.null,
            logical(1)
        )
    )

    has_partial_component_address <- any(
        !vapply(
            list(street_nm, city_nm, state_col_nm, zip_nm),
            is.null,
            logical(1)
        )
    ) && !has_component_address

    if (!has_full_address && !has_component_address) {
        if (has_partial_component_address) {
            rlang::abort(
                paste(
                    "Component address geocoding requires all of",
                    "`street`, `city`, `state_col`, and `zip`."
                )
            )
        }

        rlang::abort(
            paste(
                "`link_context()` requires either `lat` and `lon`,",
                "`address`, or component address fields",
                "`street`, `city`, `state_col`, and `zip`."
            )
        )
    }

    geocode_args <- list(
        .data = .data,
        geocoder = geocoder,
        confirm_external = confirm_external
    )

    if (has_full_address) {
        geocode_args$address <- address_nm
    } else {
        geocode_args$street <- street_nm
        geocode_args$city <- city_nm
        geocode_args$state <- state_col_nm
        geocode_args$zip <- zip_nm
    }

    geocoded <- do.call(gc_address, geocode_args)

    do.call(
        id_tract,
        list(
            .data = geocoded,
            lat = "latitude",
            lon = "longitude",
            state = state,
            year = year,
            keep_geometry = keep_geometry,
            cache = cache
        )
    )
}
