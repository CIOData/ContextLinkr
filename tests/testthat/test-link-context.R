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

test_that("link_context() accepts quoted coordinate column names", {
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(...) {
            stop("gc_address() should not be called")
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
            latitude = 38.8977,
            longitude = -77.0365
        ),
        lat = "latitude",
        lon = "longitude",
        state = "DC"
    )

    expect_true(called_id_tract)
    expect_equal(result$tract_geoid, "11001980000")
    expect_true(result$.tract_identified)
})

test_that("link_context() accepts quoted full address column names", {
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
        address = "address",
        state = "DC",
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_true(called_gc_address)
    expect_true(called_id_tract)
    expect_true(result$.geocoded)
    expect_true(result$.tract_identified)
})

test_that("link_context() forwards tract lookup arguments to id_tract()", {
    testthat::local_mocked_bindings(
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, c("DC", "MD"))
            expect_equal(year, 2022)
            expect_true(keep_geometry)
            expect_false(cache)

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
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
        state = c("DC", "MD"),
        year = 2022,
        keep_geometry = TRUE,
        cache = FALSE
    )

    expect_true(result$.tract_identified)
    expect_equal(result$tract_geoid, "11001980000")
})

test_that("link_context() validates include_context", {
    expect_error(
        link_context(
            sample_addresses,
            lat = latitude,
            lon = longitude,
            state = "DC",
            include_context = NA
        ),
        "`include_context` must be a single non-missing logical value"
    )

    expect_error(
        link_context(
            sample_addresses,
            lat = latitude,
            lon = longitude,
            state = "DC",
            include_context = c(TRUE, FALSE)
        ),
        "`include_context` must be a single non-missing logical value"
    )
})

test_that("link_context() validates context_format", {
    expect_error(
        link_context(
            sample_addresses,
            lat = latitude,
            lon = longitude,
            state = "DC",
            context_format = "tidy"
        ),
        "`format` must be one of"
    )
})

test_that("link_context() can include Cancer InFocus context", {
    skip_if_no_cif_integration()

    records <- tibble::tibble(
        id = 1,
        latitude = 38.8977,
        longitude = -77.0365
    )

    result <- link_context(
        records,
        lat = latitude,
        lon = longitude,
        state = "DC",
        include_context = TRUE,
        context_measures = "Total Population"
    )

    expect_s3_class(result, "tbl_df")
    expect_true("Total Population" %in% names(result))
    expect_true(".context_joined" %in% names(result))

    summary <- context_summary(result)

    expect_s3_class(summary, "tbl_df")
    expect_true("joined" %in% names(summary))
    expect_true("total" %in% names(summary))
    expect_true("join_rate" %in% names(summary))
})

test_that("link_context() validates context_cache", {
    expect_error(
        link_context(
            sample_addresses,
            lat = latitude,
            lon = longitude,
            state = "DC",
            context_cache = NA
        ),
        "`context_cache` must be a single non-missing logical value"
    )
})

test_that("link_context() validates context_refresh_cache", {
    expect_error(
        link_context(
            sample_addresses,
            lat = latitude,
            lon = longitude,
            state = "DC",
            context_refresh_cache = NA
        ),
        "`context_refresh_cache` must be a single non-missing logical value"
    )
})

test_that("link_context infers state from geocoded address output", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live integration tests."
    )

    records <- data.frame(
        person_id = "test_001",
        address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
    )

    out <- link_context(
        records,
        address = address,
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_equal(nrow(out), 1L)
    expect_true("tract_geoid" %in% names(out))
    expect_true("geocoded_state" %in% names(out))
    expect_equal(out[["geocoded_state"]][[1]], "DC")
    expect_false("addressComponents.state" %in% names(out))
})

test_that("link_context supports multi-state address batches when geocoder returns state", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live integration tests."
    )

    records <- data.frame(
        person_id = c("test_dc", "test_ky"),
        address = c(
            "1600 Pennsylvania Ave NW, Washington, DC 20500",
            "800 Rose St, Lexington, KY 40536"
        )
    )

    out <- link_context(
        records,
        address = address,
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_equal(nrow(out), 2L)
    expect_true("tract_geoid" %in% names(out))
    expect_true("geocoded_state" %in% names(out))
    expect_setequal(out[["geocoded_state"]], c("DC", "KY"))
    expect_false(".link_context_state" %in% names(out))
})
