#' Link individual records to Census tract geography
#'
#' `link_context()` is an end-to-end convenience wrapper for linking
#' individual-level records to Census tract geography. It can either use
#' existing latitude/longitude columns or geocode address fields before
#' identifying Census tracts.
#'
#' By default, this function returns the input data with geocoding metadata,
#' when geocoding is used, and tract identification fields from [id_tract()].
#' If `include_context = TRUE`, it retrieves selected Cancer InFocus contextual
#' variables and joins them to the linked records.
#'
#' Use [link_summary()], [link_successes()], and [link_failures()] to review
#' linked output after geocoding and tract identification.
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
#' @param state Optional state abbreviation, name, FIPS code, or vector of states
#'   used to limit Census tract lookup. If omitted in coordinate-based
#'   workflows, ContextLinkr attempts to infer state from latitude and longitude
#'   using state polygons from [tigris::states()]. If omitted in address-based
#'   workflows, ContextLinkr uses geocoded state information when available.
#'   Providing `state` explicitly overrides inferred state values.
#' @param geocoder Geocoder passed to [gc_address()] when geocoding is needed.
#' @param confirm_external Logical. Must be `TRUE` before address data are sent
#'   to an external geocoding service.
#' @param year Census tract boundary year passed to [id_tract()].
#' @param keep_geometry Logical. Whether to keep tract geometry in the output.
#'   Passed to [id_tract()].
#' @param include_context Logical. If `TRUE`, retrieve Cancer InFocus
#'   contextual variables for successfully linked Census tracts and join them
#'   back to the linked records. Defaults to `FALSE`.
#' @param context_measures Optional character vector of Cancer InFocus measure
#'   definitions to retrieve when `include_context = TRUE`. If `NULL`, all
#'   available measures may be retrieved.
#' @param context_format Output format requested from [get_context()] when
#'   `include_context = TRUE`. Defaults to `"wide"` because linked
#'   individual-level records generally require one row per geography for
#'   joining.
#' @param context_cache Logical. If `TRUE`, hosted Cancer InFocus context files
#'   are cached locally before reading when `include_context = TRUE`.
#' @param context_refresh_cache Logical. If `TRUE`, hosted Cancer InFocus
#'   context files are downloaded again even when cached copies exist. Ignored
#'   when `context_cache = FALSE`.
#' @param cache Logical. Whether to use tigris caching during tract lookup.
#'   Passed to [id_tract()].
#'
#' @return A tibble containing the original records plus geocoding and/or
#'   Census tract fields. If `include_context = TRUE`, the output also includes
#'   selected Cancer InFocus contextual variables and context-join metadata.
#'
#' @seealso [gc_address()], [id_tract()], [link_summary()],
#'   [link_successes()], [link_failures()]
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
        state = NULL,
        geocoder = c("census_batch", "census_single", "osm"),
        confirm_external = FALSE,
        year = 2023,
        keep_geometry = FALSE,
        context_measures = NULL,
        context_format = "wide",
        include_context = FALSE,
        context_cache = TRUE,
        context_refresh_cache = FALSE,
        cache = TRUE
) {
    if (!is.data.frame(.data)) {
        rlang::abort("`.data` must be a data frame.")
    }

    if (!is.logical(include_context) || length(include_context) != 1 || is.na(include_context)) {
        rlang::abort("`include_context` must be a single non-missing logical value.")
    }

    if (!is.logical(context_cache) || length(context_cache) != 1 || is.na(context_cache)) {
        rlang::abort("`context_cache` must be a single non-missing logical value.")
    }

    if (!is.logical(context_refresh_cache) ||
        length(context_refresh_cache) != 1 ||
        is.na(context_refresh_cache)) {
        rlang::abort("`context_refresh_cache` must be a single non-missing logical value.")
    }

    validate_context_format(context_format)

    geocoder <- match.arg(geocoder)

    lat_nm <- col_arg_name(rlang::enquo(lat))
    lon_nm <- col_arg_name(rlang::enquo(lon))

    has_lat <- !is.null(lat_nm)
    has_lon <- !is.null(lon_nm)

    if (xor(has_lat, has_lon)) {
        rlang::abort("Both `lat` and `lon` must be supplied together.")
    }

    if (has_lat && has_lon) {
        coordinate_data <- tibble::as_tibble(.data)

        if (is.null(state)) {
            coordinate_data[[".link_context_state"]] <- infer_state_from_coordinates(
                .data = coordinate_data,
                lat = lat_nm,
                lon = lon_nm,
                year = year,
                cache = cache
            )

            result <- id_tract_by_state(
                .data = coordinate_data,
                lat = lat_nm,
                lon = lon_nm,
                state_col = ".link_context_state",
                year = year,
                keep_geometry = keep_geometry,
                cache = cache
            )
        } else {
            result <- do.call(
                id_tract,
                list(
                    .data = coordinate_data,
                    lat = lat_nm,
                    lon = lon_nm,
                    state = state,
                    year = year,
                    keep_geometry = keep_geometry,
                    cache = cache
                )
            )
        }
    } else {
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

        geocoded <- prepare_link_context_state(
            geocoded = geocoded,
            state = state
        )

        result <- id_tract_by_state(
            .data = geocoded,
            lat = "latitude",
            lon = "longitude",
            state_col = ".link_context_state",
            year = year,
            keep_geometry = keep_geometry,
            cache = cache
        )
    }

    # Keep context enrichment as the final step so both coordinate-based
    # and geocoded workflows share the same post-linkage behavior.
    if (include_context) {
        if (context_format != "wide") {
            rlang::abort(
                paste(
                    "`context_format = \"long\"` is not yet supported inside",
                    "`link_context()` because it would create multiple rows per",
                    "individual record. Use `get_context()` directly for long",
                    "Cancer InFocus output."
                )
            )
        }

        result <- add_context(
            result,
            tract_col = "tract_geoid",
            measures = context_measures,
            use_cache = context_cache,
            refresh_cache = context_refresh_cache
        )
    }

    result
}
