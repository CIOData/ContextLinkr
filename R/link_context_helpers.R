# Internal helpers for link_context().

prepare_link_context_state <- function(geocoded, state = NULL) {
    if (!is.null(state)) {
        geocoded[[".link_context_state"]] <- state
        return(geocoded)
    }

    if ("geocoded_state" %in% names(geocoded)) {
        geocoded[[".link_context_state"]] <- geocoded[["geocoded_state"]]
        return(geocoded)
    }

    rlang::abort(
        paste(
            "`state` was not supplied and state could not be inferred from the",
            "geocoded address output. Provide `state` explicitly, or use a geocoder",
            "configuration that returns `geocoded_state`."
        )
    )
}

id_tract_by_state <- function(.data, lat, lon, state_col, year, keep_geometry, cache) {
    state_values <- unique(stats::na.omit(as.character(.data[[state_col]])))
    state_values <- state_values[nzchar(state_values)]

    if (length(state_values) == 0L) {
        rlang::abort(
            paste(
                "No valid state values were available for tract lookup.",
                "Check geocoding results, coordinate values, or provide `state` explicitly."
            )
        )
    }

    pieces <- lapply(state_values, function(state_value) {
        state_data <- .data[as.character(.data[[state_col]]) == state_value, , drop = FALSE]

        do.call(
            id_tract,
            list(
                .data = state_data,
                lat = lat,
                lon = lon,
                state = state_value,
                year = year,
                keep_geometry = keep_geometry,
                cache = cache
            )
        )
    })

    out <- do.call(rbind, pieces)

    out[[".link_context_state"]] <- NULL

    tibble::as_tibble(out)
}

infer_state_from_coordinates <- function(.data, lat, lon, year = 2023, cache = TRUE) {
    lat_values <- suppressWarnings(as.numeric(.data[[lat]]))
    lon_values <- suppressWarnings(as.numeric(.data[[lon]]))

    if (all(is.na(lat_values)) || all(is.na(lon_values))) {
        rlang::abort(
            paste(
                "State could not be inferred from coordinates because",
                "`lat` and `lon` do not contain usable numeric values."
            )
        )
    }

    point_data <- tibble::as_tibble(.data)
    point_data[[".contextlinkr_row_id"]] <- seq_len(nrow(point_data))

    points <- sf::st_as_sf(
        point_data,
        coords = c(lon, lat),
        crs = 4326,
        remove = FALSE
    )

    states <- tigris::states(
        year = year,
        cb = TRUE,
        class = "sf"
    )

    states <- sf::st_transform(states, sf::st_crs(points))

    state_cols <- c("STATEFP", "STUSPS", "NAME", "geometry")
    state_cols <- intersect(state_cols, names(states))

    joined <- sf::st_join(
        points,
        states[, state_cols],
        join = sf::st_intersects,
        left = TRUE
    )

    joined_df <- sf::st_drop_geometry(joined)

    inferred <- joined_df[["STUSPS"]][
        match(point_data[[".contextlinkr_row_id"]], joined_df[[".contextlinkr_row_id"]])
    ]

    inferred
}
