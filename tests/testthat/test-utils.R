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
