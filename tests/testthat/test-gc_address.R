test_that("gc_address requires a data frame", {
    expect_error(
        gc_address("not a data frame", confirm_external = TRUE),
        "`\\.data` must be a data frame"
    )
})

test_that("gc_address requires explicit external confirmation", {
    df <- tibble::tibble(
        street = "1600 Pennsylvania Avenue NW",
        city = "Washington",
        state = "DC",
        zip = "20500"
    )

    expect_error(
        gc_address(
            df,
            street = street,
            city = city,
            state = state,
            zip = zip
        ),
        "`confirm_external` must be TRUE"
    )
})

test_that("gc_address requires address fields", {
    df <- tibble::tibble(id = 1)

    expect_error(
        gc_address(df, confirm_external = TRUE),
        "Provide either `address`"
    )
})

test_that("gc_address errors when requested columns are missing", {
    df <- tibble::tibble(
        street = "1600 Pennsylvania Avenue NW",
        city = "Washington"
    )

    expect_error(
        gc_address(
            df,
            street = street,
            city = city,
            state = state,
            zip = zip,
            confirm_external = TRUE
        ),
        "columns were not found"
    )
})

test_that("gc_address accepts quoted column names during validation", {
    df <- tibble::tibble(
        street = "1600 Pennsylvania Avenue NW",
        city = "Washington",
        state = "DC",
        zip = "20500"
    )

    expect_error(
        gc_address(
            df,
            street = "missing_street",
            city = "city",
            state = "state",
            zip = "zip",
            confirm_external = TRUE
        ),
        "missing_street"
    )
})
