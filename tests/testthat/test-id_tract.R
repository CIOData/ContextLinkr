test_that("id_tract requires a data frame", {
    expect_error(
        id_tract("not a data frame", lat = latitude, lon = longitude, state = "DC"),
        "`\\.data` must be a data frame"
    )
})

test_that("id_tract requires state in first version", {
    df <- tibble::tibble(
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        id_tract(df, lat = latitude, lon = longitude),
        "`state` is required"
    )
})

test_that("id_tract requires latitude and longitude", {
    df <- tibble::tibble(id = 1)

    expect_error(
        id_tract(df, state = "DC"),
        "Both `lat` and `lon` must be provided"
    )
})

test_that("id_tract errors when coordinate columns are missing", {
    df <- tibble::tibble(id = 1)

    expect_error(
        id_tract(df, lat = latitude, lon = longitude, state = "DC"),
        "columns were not found"
    )
})

test_that("id_tract errors when no valid coordinates exist", {
    df <- tibble::tibble(
        latitude = NA_real_,
        longitude = NA_real_
    )

    expect_error(
        id_tract(df, lat = latitude, lon = longitude, state = "DC"),
        "No valid coordinate pairs were found"
    )
})

test_that("id_tract accepts quoted coordinate column names during validation", {
    df <- tibble::tibble(
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        id_tract(df, lat = "missing_latitude", lon = "longitude", state = "DC"),
        "missing_latitude"
    )
})

test_that("add_tract_status identifies rows with tract GEOIDs", {
    x <- tibble::tibble(
        id = 1:3,
        tract_geoid = c("11001980000", NA_character_, "11001006202")
    )

    out <- add_tract_status(x, state = "DC", year = 2020)

    expect_equal(out$.tract_identified, c(TRUE, FALSE, TRUE))
    expect_equal(out$.tract_state, c("DC", "DC", "DC"))
    expect_equal(out$.tract_year, c(2020, 2020, 2020))
})

test_that("id_tract validates keep_geometry", {
    df <- tibble::tibble(
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        id_tract(
            df,
            lat = latitude,
            lon = longitude,
            state = "DC",
            keep_geometry = NA
        ),
        "`keep_geometry` must be TRUE or FALSE"
    )
})

test_that("id_tract validates cache", {
    df <- tibble::tibble(
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        id_tract(
            df,
            lat = latitude,
            lon = longitude,
            state = "DC",
            cache = NA
        ),
        "`cache` must be TRUE or FALSE"
    )
})
