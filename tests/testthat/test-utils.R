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
