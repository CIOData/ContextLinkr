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
