sample_addresses <- tibble::tibble(
    id = 1:5,
    street = c(
        "1600 Pennsylvania Avenue NW",
        "1 First Street NE",
        "350 Fifth Avenue",
        "11 Wall Street",
        "405 Lexington Avenue"
    ),
    city = c(
        "Washington",
        "Washington",
        "New York",
        "New York",
        "New York"
    ),
    state = c(
        "DC",
        "DC",
        "NY",
        "NY",
        "NY"
    ),
    zip = c(
        "20500",
        "20543",
        "10118",
        "10005",
        "10174"
    )
)

usethis::use_data(sample_addresses, overwrite = TRUE)
