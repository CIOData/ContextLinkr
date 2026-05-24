#' Identify Census tracts for coordinate data
#'
#' Identifies the Census tract containing each record using latitude and
#' longitude coordinates.
#'
#' @param .data A data frame containing coordinate columns.
#' @param lat Column containing latitude values.
#' @param lon Column containing longitude values.
#' @param year Census boundary year. Defaults to 2020.
#' @param state Optional two-letter state abbreviation or state FIPS code used to
#'   limit the Census tract boundary download. If `NULL`, tracts are downloaded
#'   for all states represented by the coordinates' bounding box in future
#'   versions. For this first version, `state` is required.
#' @param keep_geometry Logical. If `TRUE`, returns an sf object. If `FALSE`,
#'   returns a tibble.
#'
#' @return The input data with Census tract GEOID and tract metadata appended.
#'
#' @examples
#' \dontrun{
#' id_tract(
#'   sample_addresses_geocoded,
#'   lat = latitude,
#'   lon = longitude,
#'   state = "DC"
#' )
#' }
#'
#' @export
id_tract <- function(
        .data,
        lat,
        lon,
        year = 2020,
        state = NULL,
        keep_geometry = FALSE
) {
    if (!is.data.frame(.data)) {
        stop("`.data` must be a data frame.", call. = FALSE)
    }

    if (is.null(state)) {
        stop(
            "`state` is required in this first version of `id_tract()`.",
            call. = FALSE
        )
    }

    lat_col <- col_arg_name(rlang::enquo(lat))
    lon_col <- col_arg_name(rlang::enquo(lon))

    if (is.null(lat_col) || is.null(lon_col)) {
        stop("Both `lat` and `lon` must be provided.", call. = FALSE)
    }

    missing_cols <- setdiff(c(lat_col, lon_col), names(.data))

    if (length(missing_cols) > 0) {
        stop(
            "The following columns were not found in `.data`: ",
            paste(missing_cols, collapse = ", "),
            call. = FALSE
        )
    }

    df_input <- tibble::as_tibble(.data)

    df_input[[lat_col]] <- suppressWarnings(as.numeric(df_input[[lat_col]]))
    df_input[[lon_col]] <- suppressWarnings(as.numeric(df_input[[lon_col]]))

    valid_coords <- !is.na(df_input[[lat_col]]) & !is.na(df_input[[lon_col]])

    if (!any(valid_coords)) {
        stop("No valid coordinate pairs were found.", call. = FALSE)
    }

    points <- sf::st_as_sf(
        df_input[valid_coords, , drop = FALSE],
        coords = c(lon_col, lat_col),
        crs = 4326,
        remove = FALSE
    )

    tracts <- tigris::tracts(
        state = state,
        year = year,
        cb = TRUE,
        class = "sf"
    )

    tracts <- sf::st_transform(tracts, sf::st_crs(points))

    joined <- sf::st_join(
        points,
        tracts[, c("GEOID", "STATEFP", "COUNTYFP", "TRACTCE", "NAME")],
        join = sf::st_within,
        left = TRUE
    )

    names(joined)[names(joined) == "GEOID"] <- "tract_geoid"
    names(joined)[names(joined) == "STATEFP"] <- "state_fips"
    names(joined)[names(joined) == "COUNTYFP"] <- "county_fips"
    names(joined)[names(joined) == "TRACTCE"] <- "tract_code"
    names(joined)[names(joined) == "NAME"] <- "tract_name"

    out <- df_input
    out$tract_geoid <- NA_character_
    out$state_fips <- NA_character_
    out$county_fips <- NA_character_
    out$tract_code <- NA_character_
    out$tract_name <- NA_character_

    out[valid_coords, c(
        "tract_geoid",
        "state_fips",
        "county_fips",
        "tract_code",
        "tract_name"
    )] <- sf::st_drop_geometry(joined)[, c(
        "tract_geoid",
        "state_fips",
        "county_fips",
        "tract_code",
        "tract_name"
    )]

    out <- add_tract_status(out, state = state, year = year)

    if (keep_geometry) {
        return(sf::st_as_sf(
            out,
            coords = c(lon_col, lat_col),
            crs = 4326,
            remove = FALSE
        ))
    }

    tibble::as_tibble(out)
}
