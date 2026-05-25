test_that("link_context() requires a data frame", {
    expect_error(
        link_context(
            "not a data frame",
            lat = latitude,
            lon = longitude,
            state = "DC"
        ),
        "`\\.data` must be a data frame"
    )
})

test_that("link_context() requires state for tract lookup", {
    expect_error(
        link_context(
            tibble::tibble(latitude = 38.8977, longitude = -77.0365),
            lat = latitude,
            lon = longitude
        ),
        "`state` is required"
    )
})

test_that("link_context() requires both latitude and longitude together", {
    expect_error(
        link_context(
            tibble::tibble(latitude = 38.8977),
            lat = latitude,
            state = "DC"
        ),
        "Both `lat` and `lon` must be supplied together"
    )

    expect_error(
        link_context(
            tibble::tibble(longitude = -77.0365),
            lon = longitude,
            state = "DC"
        ),
        "Both `lat` and `lon` must be supplied together"
    )
})

test_that("link_context() requires coordinates or address inputs", {
    expect_error(
        link_context(
            tibble::tibble(id = 1),
            state = "DC"
        ),
        "requires either"
    )
})

test_that("link_context() requires complete component address fields", {
    expect_error(
        link_context(
            tibble::tibble(
                street = "1600 Pennsylvania Ave NW",
                city = "Washington"
            ),
            street = street,
            city = city,
            state = "DC"
        ),
        "Component address geocoding requires all of"
    )
})

test_that("link_context() skips geocoding when coordinates are supplied", {
    called_gc_address <- FALSE
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(...) {
            called_gc_address <<- TRUE
            stop("gc_address() should not be called")
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            called_id_tract <<- TRUE

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")
            expect_equal(year, 2023)
            expect_false(keep_geometry)
            expect_true(cache)

            dplyr_free_result <- .data
            dplyr_free_result$tract_geoid <- "11001980000"
            dplyr_free_result$.tract_identified <- TRUE
            dplyr_free_result
        }
    )

    result <- link_context(
        tibble::tibble(
            id = 1,
            latitude = 38.8977,
            longitude = -77.0365
        ),
        lat = latitude,
        lon = longitude,
        state = "DC"
    )

    expect_false(called_gc_address)
    expect_true(called_id_tract)
    expect_equal(result$tract_geoid, "11001980000")
    expect_true(result$.tract_identified)
})

test_that("link_context() geocodes full address before tract lookup", {
    called_gc_address <- FALSE
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(.data, address, geocoder, confirm_external) {
            called_gc_address <<- TRUE

            expect_equal(address, "address")
            expect_equal(geocoder, "census_single")
            expect_true(confirm_external)

            .data$latitude <- 38.8977
            .data$longitude <- -77.0365
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            called_id_tract <<- TRUE

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")
            expect_true(".geocoded" %in% names(.data))

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        tibble::tibble(
            id = 1,
            address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
        ),
        address = address,
        state = "DC",
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_true(called_gc_address)
    expect_true(called_id_tract)
    expect_true(result$.geocoded)
    expect_true(result$.tract_identified)
    expect_equal(result$tract_geoid, "11001980000")
})

test_that("link_context() geocodes component address fields before tract lookup", {
    called_gc_address <- FALSE
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(.data, street, city, state, zip, geocoder, confirm_external) {
            called_gc_address <<- TRUE

            expect_equal(street, "street")
            expect_equal(city, "city")
            expect_equal(state, "state_abbr")
            expect_equal(zip, "zip")
            expect_equal(geocoder, "census_single")
            expect_true(confirm_external)

            .data$latitude <- 38.8977
            .data$longitude <- -77.0365
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            called_id_tract <<- TRUE

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        tibble::tibble(
            id = 1,
            street = "1600 Pennsylvania Ave NW",
            city = "Washington",
            state_abbr = "DC",
            zip = "20500"
        ),
        street = street,
        city = city,
        state_col = state_abbr,
        zip = zip,
        state = "DC",
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_true(called_gc_address)
    expect_true(called_id_tract)
    expect_true(result$.geocoded)
    expect_true(result$.tract_identified)
})
