widen_context_data <- function(context_data) {
    if (!is.data.frame(context_data)) {
        rlang::abort("`context_data` must be a data frame.")
    }

    required_cols <- c("GEOID", "def", "value")
    missing_cols <- setdiff(required_cols, names(context_data))

    if (length(missing_cols) > 0) {
        rlang::abort(
            paste0(
                "`context_data` must contain required column(s): ",
                paste(missing_cols, collapse = ", "),
                "."
            )
        )
    }

    context_data <- context_data[
        !is.na(context_data[["def"]]) & context_data[["def"]] != "",
        ,
        drop = FALSE
    ]

    label_cols <- intersect(
        c("Tract", "County", "State"),
        names(context_data)
    )

    geoid_values <- unique(context_data[["GEOID"]])

    geo_labels <- data.frame(
        GEOID = geoid_values,
        stringsAsFactors = FALSE
    )

    for (col in label_cols) {
        geo_labels[[col]] <- vapply(
            geoid_values,
            function(geoid) {
                vals <- context_data[[col]][context_data[["GEOID"]] == geoid]
                vals <- vals[!is.na(vals) & vals != ""]

                if (length(vals) == 0) {
                    return(NA_character_)
                }

                as.character(vals[[1]])
            },
            character(1)
        )
    }

    context_values <- context_data[
        ,
        c("GEOID", "def", "value"),
        drop = FALSE
    ]

    context_values <- unique(context_values)

    duplicate_keys <- duplicated(context_values[c("GEOID", "def")]) |
        duplicated(context_values[c("GEOID", "def")], fromLast = TRUE)

    if (any(duplicate_keys)) {
        rlang::abort(
            paste0(
                "`context_data` must contain one value per `GEOID` and ",
                "`def` before it can be widened."
            )
        )
    }

    context_wide <- tidyr::pivot_wider(
        tibble::as_tibble(context_values),
        id_cols = "GEOID",
        names_from = "def",
        values_from = "value"
    )

    context_wide <- merge(
        geo_labels,
        as.data.frame(context_wide),
        by = "GEOID",
        all.x = TRUE,
        sort = FALSE
    )

    context_wide <- tibble::as_tibble(context_wide)

    if (anyDuplicated(context_wide[["GEOID"]])) {
        rlang::abort(
            "`get_context(format = \"wide\")` must return one row per `GEOID`."
        )
    }

    context_wide
}
