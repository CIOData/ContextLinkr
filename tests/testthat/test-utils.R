test_that("build_geocoder_queries creates census batch query", {
    queries <- build_geocoder_queries("census_batch")

    expect_length(queries, 1)
    expect_equal(queries[[1]]$method, "census")
    expect_equal(queries[[1]]$mode, "batch")
})

test_that("build_geocoder_queries creates census single query", {
    queries <- build_geocoder_queries("census_single")

    expect_length(queries, 1)
    expect_equal(queries[[1]]$method, "census")
    expect_equal(queries[[1]]$mode, "single")
})

test_that("build_geocoder_queries creates osm query", {
    queries <- build_geocoder_queries("osm")

    expect_length(queries, 1)
    expect_equal(queries[[1]]$method, "osm")
    expect_null(queries[[1]]$mode)
})

test_that("build_geocoder_queries preserves requested order", {
    queries <- build_geocoder_queries(c("census_batch", "osm", "census_single"))

    expect_length(queries, 3)
    expect_equal(queries[[1]]$method, "census")
    expect_equal(queries[[1]]$mode, "batch")
    expect_equal(queries[[2]]$method, "osm")
    expect_equal(queries[[3]]$method, "census")
    expect_equal(queries[[3]]$mode, "single")
})

test_that("normalize_zip pads short ZIP codes", {
    expect_equal(normalize_zip("640"), "00640")
    expect_equal(normalize_zip(640), "00640")
})

test_that("normalize_zip preserves five-character ZIP codes", {
    expect_equal(normalize_zip("40202"), "40202")
})

test_that("normalize_zip trims whitespace", {
    expect_equal(normalize_zip(" 640 "), "00640")
})

test_that("col_arg_name captures unquoted column names", {
    wrapper <- function(street) {
        col_arg_name(rlang::enquo(street))
    }

    expect_equal(wrapper(street), "street")
})

test_that("col_arg_name captures quoted column names", {
    wrapper <- function(street) {
        col_arg_name(rlang::enquo(street))
    }

    expect_equal(wrapper("street"), "street")
})

test_that("col_arg_name returns NULL for missing arguments", {
    wrapper <- function(street) {
        col_arg_name(rlang::enquo(street))
    }

    expect_null(wrapper())
})

test_that("col_arg_name returns NULL for explicit NULL", {
    wrapper <- function(street = NULL) {
        col_arg_name(rlang::enquo(street))
    }

    expect_null(wrapper(NULL))
})

test_that("add_geocode_status identifies geocoded rows", {
    x <- tibble::tibble(
        latitude = c(38.9, NA_real_),
        longitude = c(-77.0, NA_real_)
    )

    out <- add_geocode_status(x, has_full_address = FALSE)

    expect_equal(out$.geocoded, c(TRUE, FALSE))
    expect_equal(out$.geocode_input, c("components", "components"))
})

test_that("add_geocode_status identifies full address input", {
    x <- tibble::tibble(
        latitude = 38.9,
        longitude = -77.0
    )

    out <- add_geocode_status(x, has_full_address = TRUE)

    expect_true(out$.geocoded)
    expect_equal(out$.geocode_input, "address")
})

test_that("filter_status filters TRUE rows", {
    x <- tibble::tibble(
        id = 1:3,
        status = c(TRUE, FALSE, TRUE)
    )

    out <- filter_status(x, "status", TRUE)

    expect_s3_class(out, "tbl_df")
    expect_equal(out$id, c(1, 3))
})

test_that("filter_status filters FALSE rows", {
    x <- tibble::tibble(
        id = 1:3,
        status = c(TRUE, FALSE, TRUE)
    )

    out <- filter_status(x, "status", FALSE)

    expect_s3_class(out, "tbl_df")
    expect_equal(out$id, 2)
})

test_that("filter_status requires status column", {
    x <- tibble::tibble(id = 1:2)

    expect_error(
        filter_status(x, "status", TRUE),
        "must contain a `status` column"
    )
})

test_that("add_tract_status collapses multiple states", {
    x <- tibble::tibble(
        id = 1:2,
        tract_geoid = c("11001980000", "24033800105")
    )

    out <- add_tract_status(x, state = c("DC", "MD"), year = 2020)

    expect_equal(out$.tract_identified, c(TRUE, TRUE))
    expect_equal(out$.tract_state, c("DC, MD", "DC, MD"))
    expect_equal(out$.tract_year, c(2020, 2020))
})

test_that("normalize_states trims whitespace", {
    expect_equal(normalize_states(c(" DC ", "MD")), c("DC", "MD"))
})

test_that("normalize_states removes duplicate states", {
    expect_equal(normalize_states(c("DC", "MD", "DC")), c("DC", "MD"))
})

test_that("normalize_states requires state", {
    expect_error(
        normalize_states(NULL),
        "`state` is required"
    )
})

test_that("normalize_states requires character input", {
    expect_error(
        normalize_states(11),
        "`state` must be a character vector"
    )
})

test_that("normalize_states rejects missing values", {
    expect_error(
        normalize_states(c("DC", NA_character_)),
        "`state` must be a character vector"
    )
})

test_that("normalize_states rejects blank values", {
    expect_error(
        normalize_states(c("DC", "")),
        "`state` must be a character vector"
    )
})

test_that("validate_year accepts single numeric year", {
    expect_equal(validate_year(2020), 2020)
})

test_that("validate_year rejects missing year", {
    expect_error(
        validate_year(NA_real_),
        "`year` must be a single non-missing numeric value"
    )
})

test_that("validate_year rejects multiple years", {
    expect_error(
        validate_year(c(2020, 2021)),
        "`year` must be a single non-missing numeric value"
    )
})

test_that("validate_year rejects non-numeric year", {
    expect_error(
        validate_year("2020"),
        "`year` must be a single non-missing numeric value"
    )
})
