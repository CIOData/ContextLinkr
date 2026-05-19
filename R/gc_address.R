#' Geocode address data
#'
#' Geocodes records using either a single full-address column or separate street,
#' city, state, and ZIP/postal code columns.
#'
#' This function may send address information to external geocoding services.
#' Users working with protected, sensitive, or restricted data should only use
#' this function when they have permission to send those data to the selected
#' geocoding services. Otherwise, geocode in an approved secure environment and
#' use downstream ContextLinkr functions with latitude and longitude columns.
#'
#' @param .data A data frame containing address information.
#' @param address Optional column containing a full address.
#' @param street Optional column containing street address.
#' @param city Optional column containing city.
#' @param state Optional column containing state.
#' @param zip Optional column containing ZIP or postal code.
#' @param geocoder Character vector specifying geocoding methods to use.
#'   Currently supports `"census_batch"`, `"census_single"`, and `"osm"`.
#' @param confirm_external Logical. Must be `TRUE` to confirm that the user has
#'   permission to send address data to the selected geocoding services.
#' @param quiet Logical. If `FALSE`, prints a short geocoding summary.
#'
#' @return A tibble containing the original input columns plus `latitude`,
#'   `longitude`, and geocoding metadata returned by `tidygeocoder`.
#'
#' @examples
#' sample_addresses <- tibble::tibble(
#'   street = c("1600 Pennsylvania Avenue NW"),
#'   city = c("Washington"),
#'   state = c("DC"),
#'   zip = c("20500")
#' )
#'
#' \dontrun{
#' gc_address(
#'   sample_addresses,
#'   street = street,
#'   city = city,
#'   state = state,
#'   zip = zip,
#'   confirm_external = TRUE
#' )
#' }
#'
#' @export
gc_address <- function(
        .data,
        address = NULL,
        street = NULL,
        city = NULL,
        state = NULL,
        zip = NULL,
        geocoder = c("census_batch", "census_single", "osm"),
        confirm_external = FALSE,
        quiet = FALSE
) {
    if (!is.data.frame(.data)) {
        stop("`.data` must be a data frame.", call. = FALSE)
    }

    if (!isTRUE(confirm_external)) {
        stop(
            "`confirm_external` must be TRUE before address data are sent to geocoding services.",
            call. = FALSE
        )
    }

    address_col <- col_arg_name(rlang::enquo(address))
    street_col  <- col_arg_name(rlang::enquo(street))
    city_col    <- col_arg_name(rlang::enquo(city))
    state_col   <- col_arg_name(rlang::enquo(state))
    zip_col     <- col_arg_name(rlang::enquo(zip))

    has_full_address <- !is.null(address_col)
    has_components <- any(!vapply(
        list(street_col, city_col, state_col, zip_col),
        is.null,
        logical(1)
    ))

    if (!has_full_address && !has_components) {
        stop(
            "Provide either `address` or at least one of `street`, `city`, `state`, or `zip`.",
            call. = FALSE
        )
    }

    cols_to_check <- c(address_col, street_col, city_col, state_col, zip_col)
    cols_to_check <- cols_to_check[!is.na(cols_to_check) & nzchar(cols_to_check)]

    missing_cols <- setdiff(cols_to_check, names(.data))

    if (length(missing_cols) > 0) {
        stop(
            "The following columns were not found in `.data`: ",
            paste(missing_cols, collapse = ", "),
            call. = FALSE
        )
    }

    geocoder <- match.arg(
        geocoder,
        choices = c("census_batch", "census_single", "osm"),
        several.ok = TRUE
    )

    query_list <- build_geocoder_queries(geocoder)

    df_input <- tibble::as_tibble(.data)

    if (!is.null(zip_col)) {
        df_input[[zip_col]] <- stringr::str_pad(
            as.character(df_input[[zip_col]]),
            width = 5,
            side = "left",
            pad = "0"
        )
    }

    result <- tidygeocoder::geocode_combine(
        df_input,
        queries = query_list,
        global_params = list(
            address = address_col,
            street = street_col,
            city = city_col,
            state = state_col,
            postalcode = zip_col
        ),
        lat = "latitude",
        long = "longitude"
    )

    matched <- sum(!is.na(result$latitude) & !is.na(result$longitude))
    total <- nrow(result)
    match_rate <- if (total > 0) matched / total else NA_real_

    attr(result, "contextlinkr_geocode_summary") <- list(
        matched = matched,
        total = total,
        match_rate = match_rate,
        geocoder = geocoder
    )

    if (!quiet) {
        message(
            "Matched ",
            matched,
            " of ",
            total,
            " records (",
            round(match_rate * 100, 1),
            "%)."
        )
    }

    result
}


col_arg_name <- function(x) {
    expr <- rlang::quo_get_expr(x)

    if (rlang::quo_is_missing(x) || rlang::is_null(expr)) {
        return(NULL)
    }

    rlang::as_name(x)
}


build_geocoder_queries <- function(geocoder) {
    queries <- list()

    if ("census_batch" %in% geocoder) {
        queries[[length(queries) + 1]] <- list(method = "census", mode = "batch")
    }

    if ("census_single" %in% geocoder) {
        queries[[length(queries) + 1]] <- list(method = "census", mode = "single")
    }

    if ("osm" %in% geocoder) {
        queries[[length(queries) + 1]] <- list(method = "osm")
    }

    queries
}
