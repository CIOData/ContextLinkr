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
        !is.na(context_data$def) & context_data$def != "",
        ,
        drop = FALSE
    ]

    id_cols <- intersect(
        c("GEOID", "Tract", "County", "State"),
        names(context_data)
    )

    context_data <- context_data[
        ,
        unique(c(id_cols, "def", "value")),
        drop = FALSE
    ]

    tidyr::pivot_wider(
        tibble::as_tibble(context_data),
        id_cols = tidyselect::all_of(id_cols),
        names_from = "def",
        values_from = "value"
    )
}
