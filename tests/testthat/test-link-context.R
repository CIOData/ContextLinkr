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

test_that("link_context() requires both latitude and longitude together", {
    expect_error(
        link_context(
            data.frame(latitude = 38.8977),
            lat = latitude,
            state = "DC"
        ),
        "Both `lat` and `lon` must be supplied together"
    )

    expect_error(
        link_context(
            data.frame(longitude = -77.0365),
            lon = longitude,
            state = "DC"
        ),
        "Both `lat` and `lon` must be supplied together"
    )
})

test_that("link_context() requires coordinates or address inputs", {
    expect_error(
        link_context(
            data.frame(id = 1)
        ),
        "requires either"
    )
})

test_that("link_context() requires complete component address fields", {
    expect_error(
        link_context(
            data.frame(
                street = "1600 Pennsylvania Ave NW",
                city = "Washington"
            ),
            street = street,
            city = city
        ),
        "Component address geocoding requires all of"
    )
})

test_that("link_context() validates include_context", {
    records <- data.frame(
        id = 1,
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        link_context(
            records,
            lat = latitude,
            lon = longitude,
            state = "DC",
            include_context = NA
        ),
        "`include_context` must be a single non-missing logical value"
    )

    expect_error(
        link_context(
            records,
            lat = latitude,
            lon = longitude,
            state = "DC",
            include_context = c(TRUE, FALSE)
        ),
        "`include_context` must be a single non-missing logical value"
    )
})

test_that("link_context() validates context_cache", {
    records <- data.frame(
        id = 1,
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        link_context(
            records,
            lat = latitude,
            lon = longitude,
            state = "DC",
            context_cache = NA
        ),
        "`context_cache` must be a single non-missing logical value"
    )
})

test_that("link_context() validates context_refresh_cache", {
    records <- data.frame(
        id = 1,
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        link_context(
            records,
            lat = latitude,
            lon = longitude,
            state = "DC",
            context_refresh_cache = NA
        ),
        "`context_refresh_cache` must be a single non-missing logical value"
    )
})

test_that("link_context() validates context_format", {
    records <- data.frame(
        id = 1,
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        link_context(
            records,
            lat = latitude,
            lon = longitude,
            state = "DC",
            context_format = "tidy"
        ),
        "`format` must be one of"
    )
})

test_that("link_context() skips geocoding when coordinates and explicit state are supplied", {
    called_gc_address <- FALSE
    called_infer_state <- FALSE
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(...) {
            called_gc_address <<- TRUE
            stop("gc_address() should not be called")
        },
        infer_state_from_coordinates = function(...) {
            called_infer_state <<- TRUE
            stop("infer_state_from_coordinates() should not be called")
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            called_id_tract <<- TRUE

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")
            expect_equal(year, 2023)
            expect_false(keep_geometry)
            expect_true(cache)

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            id = 1,
            latitude = 38.8977,
            longitude = -77.0365
        ),
        lat = latitude,
        lon = longitude,
        state = "DC"
    )

    expect_false(called_gc_address)
    expect_false(called_infer_state)
    expect_true(called_id_tract)
    expect_equal(result$tract_geoid, "11001980000")
    expect_true(result$.tract_identified)
})

test_that("link_context() infers state for coordinate lookup when state is omitted", {
    called_infer_state <- FALSE
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(...) {
            stop("gc_address() should not be called")
        },
        infer_state_from_coordinates = function(.data, lat, lon, year, cache) {
            called_infer_state <<- TRUE

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(year, 2023)
            expect_true(cache)

            "KY"
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            called_id_tract <<- TRUE

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "KY")
            expect_true(".link_context_state" %in% names(.data))

            .data$tract_geoid <- "21067003600"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            id = 1,
            latitude = 38.0336,
            longitude = -84.5037
        ),
        lat = latitude,
        lon = longitude
    )

    expect_true(called_infer_state)
    expect_true(called_id_tract)
    expect_equal(result$tract_geoid, "21067003600")
    expect_true(result$.tract_identified)
    expect_false(".link_context_state" %in% names(result))
})

test_that("link_context() supports multi-state coordinate lookup after state inference", {
    states_seen <- character(0)

    testthat::local_mocked_bindings(
        infer_state_from_coordinates = function(.data, lat, lon, year, cache) {
            c("KY", "VA")
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            .data$tract_geoid <- ifelse(
                state == "KY",
                "21067003600",
                "51760010500"
            )
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            person_id = c("test_ky", "test_va"),
            latitude = c(38.0336, 37.54588),
            longitude = c(-84.5037, -77.43923)
        ),
        lat = latitude,
        lon = longitude
    )

    expect_setequal(states_seen, c("KY", "VA"))
    expect_equal(nrow(result), 2L)
    expect_true(all(result$.tract_identified))
    expect_false(".link_context_state" %in% names(result))
})

test_that("link_context() errors clearly when coordinate state cannot be inferred", {
    testthat::local_mocked_bindings(
        infer_state_from_coordinates = function(.data, lat, lon, year, cache) {
            rep(NA_character_, nrow(.data))
        }
    )

    expect_error(
        link_context(
            data.frame(
                person_id = "test_missing",
                latitude = NA_real_,
                longitude = NA_real_
            ),
            lat = latitude,
            lon = longitude
        ),
        "No valid state values were available for tract lookup"
    )
})

test_that("link_context() accepts quoted coordinate column names", {
    called_id_tract <- FALSE

    testthat::local_mocked_bindings(
        gc_address = function(...) {
            stop("gc_address() should not be called")
        },
        infer_state_from_coordinates = function(...) {
            stop("infer_state_from_coordinates() should not be called")
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
        data.frame(
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
        data.frame(
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

test_that("link_context() geocodes full address and uses geocoded state", {
    called_gc_address <- FALSE
    states_seen <- character(0)

    testthat::local_mocked_bindings(
        gc_address = function(.data, address, geocoder, confirm_external) {
            called_gc_address <<- TRUE

            expect_equal(address, "address")
            expect_equal(geocoder, "census_single")
            expect_true(confirm_external)

            .data$latitude <- 38.8977
            .data$longitude <- -77.0365
            .data$geocoded_state <- "DC"
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")
            expect_true(".geocoded" %in% names(.data))
            expect_true(".link_context_state" %in% names(.data))

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            id = 1,
            address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
        ),
        address = address,
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_true(called_gc_address)
    expect_equal(states_seen, "DC")
    expect_true(result$.geocoded)
    expect_true(result$.tract_identified)
    expect_equal(result$tract_geoid, "11001980000")
    expect_true("geocoded_state" %in% names(result))
    expect_false(".link_context_state" %in% names(result))
})

test_that("link_context() lets explicit state override geocoded state", {
    states_seen <- character(0)

    testthat::local_mocked_bindings(
        gc_address = function(.data, address, geocoder, confirm_external) {
            .data$latitude <- 38.8977
            .data$longitude <- -77.0365
            .data$geocoded_state <- "MD"
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            id = 1,
            address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
        ),
        address = address,
        state = "DC",
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_equal(states_seen, "DC")
    expect_true(result$.tract_identified)
})

test_that("link_context() supports multi-state address lookup after geocoding", {
    states_seen <- character(0)

    testthat::local_mocked_bindings(
        gc_address = function(.data, address, geocoder, confirm_external) {
            .data$latitude <- c(38.8977, 38.0336)
            .data$longitude <- c(-77.0365, -84.5037)
            .data$geocoded_state <- c("DC", "KY")
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            .data$tract_geoid <- ifelse(
                state == "DC",
                "11001980000",
                "21067003600"
            )
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            person_id = c("test_dc", "test_ky"),
            address = c(
                "1600 Pennsylvania Ave NW, Washington, DC 20500",
                "800 Rose St, Lexington, KY 40536"
            )
        ),
        address = address,
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_setequal(states_seen, c("DC", "KY"))
    expect_equal(nrow(result), 2L)
    expect_true(all(result$.tract_identified))
    expect_true("geocoded_state" %in% names(result))
    expect_false(".link_context_state" %in% names(result))
})

test_that("link_context() geocodes component address fields and uses geocoded state", {
    called_gc_address <- FALSE
    states_seen <- character(0)

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
            .data$geocoded_state <- "DC"
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
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
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_true(called_gc_address)
    expect_equal(states_seen, "DC")
    expect_true(result$.geocoded)
    expect_true(result$.tract_identified)
})

test_that("link_context() accepts quoted full address column names", {
    called_gc_address <- FALSE
    states_seen <- character(0)

    testthat::local_mocked_bindings(
        gc_address = function(.data, address, geocoder, confirm_external) {
            called_gc_address <<- TRUE

            expect_equal(address, "address")
            expect_equal(geocoder, "census_single")
            expect_true(confirm_external)

            .data$latitude <- 38.8977
            .data$longitude <- -77.0365
            .data$geocoded_state <- "DC"
            .data$.geocoded <- TRUE
            .data
        },
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            expect_equal(lat, "latitude")
            expect_equal(lon, "longitude")
            expect_equal(state, "DC")

            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            id = 1,
            address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
        ),
        address = "address",
        geocoder = "census_single",
        confirm_external = TRUE
    )

    expect_true(called_gc_address)
    expect_equal(states_seen, "DC")
    expect_true(result$.geocoded)
    expect_true(result$.tract_identified)
})

test_that("prepare_link_context_state uses geocoded state output", {
    geocoded <- data.frame(
        latitude = c(38.8977, 38.0336),
        longitude = c(-77.0365, -84.5037),
        geocoded_state = c("DC", "KY")
    )

    out <- prepare_link_context_state(geocoded)

    expect_true(".link_context_state" %in% names(out))
    expect_equal(out[[".link_context_state"]], c("DC", "KY"))
})

test_that("prepare_link_context_state lets explicit state override geocoded state", {
    geocoded <- data.frame(
        latitude = 38.8977,
        longitude = -77.0365,
        geocoded_state = "MD"
    )

    out <- prepare_link_context_state(geocoded, state = "DC")

    expect_true(".link_context_state" %in% names(out))
    expect_equal(out[[".link_context_state"]], "DC")
})

test_that("prepare_link_context_state errors when state cannot be inferred", {
    geocoded <- data.frame(
        latitude = 38.8977,
        longitude = -77.0365
    )

    expect_error(
        prepare_link_context_state(geocoded),
        "state could not be inferred"
    )
})

test_that("id_tract_by_state calls id_tract once per state and removes internal state column", {
    states_seen <- character(0)

    testthat::local_mocked_bindings(
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            states_seen <<- c(states_seen, state)

            .data$tract_geoid <- ifelse(
                state == "DC",
                "11001980000",
                "21067003600"
            )
            .data$.tract_identified <- TRUE
            .data
        }
    )

    records <- data.frame(
        id = c(1, 2),
        latitude = c(38.8977, 38.0336),
        longitude = c(-77.0365, -84.5037),
        .link_context_state = c("DC", "KY")
    )

    out <- id_tract_by_state(
        .data = records,
        lat = "latitude",
        lon = "longitude",
        state_col = ".link_context_state",
        year = 2023,
        keep_geometry = FALSE,
        cache = TRUE
    )

    expect_setequal(states_seen, c("DC", "KY"))
    expect_equal(nrow(out), 2L)
    expect_true(all(out$.tract_identified))
    expect_false(".link_context_state" %in% names(out))
})

test_that("id_tract_by_state errors when no valid state values are available", {
    records <- data.frame(
        id = 1,
        latitude = NA_real_,
        longitude = NA_real_,
        .link_context_state = NA_character_
    )

    expect_error(
        id_tract_by_state(
            .data = records,
            lat = "latitude",
            lon = "longitude",
            state_col = ".link_context_state",
            year = 2023,
            keep_geometry = FALSE,
            cache = TRUE
        ),
        "No valid state values were available for tract lookup"
    )
})

test_that("link_context() can include Cancer InFocus context", {
    called_add_context <- FALSE

    testthat::local_mocked_bindings(
        id_tract = function(.data, lat, lon, state, year, keep_geometry, cache) {
            .data$tract_geoid <- "11001980000"
            .data$.tract_identified <- TRUE
            .data
        },
        add_context = function(.data, tract_col, measures, use_cache, refresh_cache) {
            called_add_context <<- TRUE

            expect_equal(tract_col, "tract_geoid")
            expect_equal(measures, "Total Population")
            expect_true(use_cache)
            expect_false(refresh_cache)

            .data[["Total Population"]] <- 1000
            .data[[".context_joined"]] <- TRUE
            .data
        }
    )

    result <- link_context(
        data.frame(
            id = 1,
            latitude = 38.8977,
            longitude = -77.0365
        ),
        lat = latitude,
        lon = longitude,
        state = "DC",
        include_context = TRUE,
        context_measures = "Total Population"
    )

    expect_true(called_add_context)
    expect_true("Total Population" %in% names(result))
    expect_true(".context_joined" %in% names(result))
    expect_true(result$.context_joined)
})

test_that("link_context() rejects long context output inside linked records", {
    expect_error(
        link_context(
            data.frame(
                id = 1,
                latitude = 38.8977,
                longitude = -77.0365
            ),
            lat = latitude,
            lon = longitude,
            state = "DC",
            include_context = TRUE,
            context_format = "long"
        ),
        "`context_format = \"long\"` is not yet supported"
    )
})

test_that("infer_state_from_coordinates identifies states from coordinates", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live integration tests."
    )

    records <- data.frame(
        latitude = c(38.0336, 37.54588),
        longitude = c(-84.5037, -77.43923)
    )

    out <- infer_state_from_coordinates(
        .data = records,
        lat = "latitude",
        lon = "longitude",
        year = 2023
    )

    expect_equal(out, c("KY", "VA"))
})

test_that("infer_state_from_coordinates identifies DC from coordinates", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live integration tests."
    )

    records <- data.frame(
        latitude = 38.8977,
        longitude = -77.0365
    )

    out <- infer_state_from_coordinates(
        .data = records,
        lat = "latitude",
        lon = "longitude",
        year = 2023
    )

    expect_equal(out, "DC")
})

test_that("link_context can infer state for coordinate-based tract lookup", {
    skip_if_not(
        identical(Sys.getenv("CONTEXTLINKR_RUN_CIF_INTEGRATION"), "true"),
        message = "Set CONTEXTLINKR_RUN_CIF_INTEGRATION=true to run live integration tests."
    )

    records <- data.frame(
        person_id = "test_ky",
        latitude = 38.0336,
        longitude = -84.5037
    )

    out <- link_context(
        records,
        lat = latitude,
        lon = longitude
    )

    expect_equal(nrow(out), 1L)
    expect_true("tract_geoid" %in% names(out))
    expect_true(isTRUE(out$.tract_identified[[1]]))
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
    expect_false(".link_context_state" %in% names(out))
})

test_that("link_context supports multi-state address batches when geocoder returns state",{
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
