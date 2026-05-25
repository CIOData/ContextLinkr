col_arg_name <- function(x) {
    expr <- rlang::quo_get_expr(x)

    if (rlang::quo_is_missing(x) || rlang::is_null(expr)) {
        return(NULL)
    }

    if (rlang::is_string(expr)) {
        return(expr)
    }

    rlang::as_name(x)
}


build_geocoder_queries <- function(geocoder) {
    lapply(geocoder, function(x) {
        switch(
            x,
            census_batch = list(method = "census", mode = "batch"),
            census_single = list(method = "census", mode = "single"),
            osm = list(method = "osm"),
            stop("Unsupported geocoder: ", x, call. = FALSE)
        )
    })
}

normalize_zip <- function(x) {
    x <- as.character(x)

    x <- stringr::str_trim(x)

    stringr::str_pad(
        x,
        width = 5,
        side = "left",
        pad = "0"
    )
}

add_geocode_status <- function(x, has_full_address) {
    x$.geocoded <- !is.na(x$latitude) & !is.na(x$longitude)

    x$.geocode_input <- if (has_full_address) {
        "address"
    } else {
        "components"
    }

    x
}

check_geocode_result <- function(x) {
    if (!is.data.frame(x)) {
        stop("`x` must be a data frame.", call. = FALSE)
    }

    if (!".geocoded" %in% names(x)) {
        stop(
            "`x` must contain a `.geocoded` column. Was it created by `gc_address()`?",
            call. = FALSE
        )
    }

    invisible(x)
}

add_tract_status <- function(x, year) {
    x$.tract_identified <- !is.na(x$tract_geoid)
    x$.tract_state_fips <- x$state_fips
    x$.tract_year <- year

    x
}

check_tract_result <- function(x) {
    if (!is.data.frame(x)) {
        stop("`x` must be a data frame.", call. = FALSE)
    }

    if (!".tract_identified" %in% names(x)) {
        stop(
            "`x` must contain a `.tract_identified` column. Was it created by `id_tract()`?",
            call. = FALSE
        )
    }

    invisible(x)
}

filter_status <- function(x, status_col, value) {
    if (!is.data.frame(x)) {
        stop("`x` must be a data frame.", call. = FALSE)
    }

    if (!status_col %in% names(x)) {
        stop(
            "`x` must contain a `",
            status_col,
            "` column.",
            call. = FALSE
        )
    }

    tibble::as_tibble(x[x[[status_col]] == value, , drop = FALSE])
}

get_tract_boundaries <- function(state, year, cache = TRUE) {
    old_tigris_use_cache <- getOption("tigris_use_cache")

    if (isTRUE(cache)) {
        options(tigris_use_cache = TRUE)
    }

    on.exit(
        options(tigris_use_cache = old_tigris_use_cache),
        add = TRUE
    )

    tract_list <- lapply(state, function(s) {
        tigris::tracts(
            state = s,
            year = year,
            cb = TRUE,
            class = "sf"
        )
    })

    do.call(rbind, tract_list)
}

normalize_states <- function(state) {
    if (is.null(state)) {
        stop(
            "`state` is required in this version of `id_tract()`.",
            call. = FALSE
        )
    }

    if (!is.character(state)) {
        stop("`state` must be a character vector of one or more states.", call. = FALSE)
    }

    state <- stringr::str_trim(state)

    if (length(state) < 1 || any(is.na(state)) || any(!nzchar(state))) {
        stop("`state` must be a character vector of one or more states.", call. = FALSE)
    }

    unique(state)
}


validate_year <- function(year) {
    if (
        !is.numeric(year) ||
        length(year) != 1 ||
        is.na(year)
    ) {
        stop("`year` must be a single non-missing numeric value.", call. = FALSE)
    }

    year
}
