test_that("get_context() reports that retrieval is not yet implemented", {
    expect_error(
        get_context(
            geographies = "11001980000",
            measures = "poverty",
            geography = "tract"
        ),
        "planned but not yet implemented"
    )
})
