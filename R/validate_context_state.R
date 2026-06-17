valid_state_fips <- function() {
    c(
        "01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
        "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
        "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
        "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
        "45", "46", "47", "48", "49", "50", "51", "53", "54", "55",
        "56", "60", "66", "69", "72", "78"
    )
}

validate_context_state <- function(geographies, geography) {
    if (geography != "tract") {
        return(invisible(TRUE))
    }

    geographies <- as.character(geographies)
    geographies <- geographies[!is.na(geographies) & geographies != ""]

    invalid_format <- geographies[!grepl("^[0-9]{11}$", geographies)]

    if (length(invalid_format) > 0) {
        rlang::abort(
            paste0(
                "`geographies` must contain 11-digit Census tract GEOIDs when ",
                "`geography = \"tract\"`. Invalid value(s): ",
                paste(utils::head(invalid_format, 5), collapse = ", "),
                if (length(invalid_format) > 5) ", ..." else "",
                "."
            )
        )
    }

    state_fips <- unique(substr(geographies, 1, 2))
    invalid_state_fips <- setdiff(state_fips, valid_state_fips())

    if (length(invalid_state_fips) > 0) {
        rlang::abort(
            paste0(
                "`geographies` contains tract GEOIDs with unsupported state ",
                "FIPS code(s): ",
                paste(invalid_state_fips, collapse = ", "),
                ". Hosted tract context data are only available for recognized ",
                "state and territory FIPS codes."
            )
        )
    }

    invisible(TRUE)
}
