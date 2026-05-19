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
