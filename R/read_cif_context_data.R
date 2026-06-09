read_cif_context_data <- function(geography = "tract", release = "Current") {
    url <- cif_context_url(
        geography = geography,
        release = release
    )

    temp <- tempfile(fileext = ".fst")
    on.exit(unlink(temp), add = TRUE)

    utils::download.file(
        url = url,
        destfile = temp,
        mode = "wb",
        quiet = TRUE
    )

    tibble::as_tibble(
        fst::read_fst(temp)
    )
}
