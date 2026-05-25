
# ContextLinkr

ContextLinkr is an R package for linking individual-level records to
geographic contextual data for multilevel health research.

The package is currently in early development. The first implemented
function is `gc_address()`, which geocodes address data using
configurable geocoding services.

## Installation

``` r
# Not yet available from CRAN.
# Development installation instructions will be added after the GitHub
# repository is public.
```

## Basic geocoding example

`gc_address()` accepts either a full address column or separate street,
city, state, and ZIP code columns.

Because geocoding may send address information to external services,
users must explicitly confirm that they have permission to do so.

``` r
library(ContextLinkr)

res <- gc_address(
  sample_addresses,
  street = street,
  city = city,
  state = state,
  zip = zip,
  geocoder = "osm",
  confirm_external = TRUE
)

res
geocode_summary(res)
geocode_successes(res)
geocode_failures(res)
```

Users working with protected, sensitive, or restricted data should
geocode only in approved computing environments. If coordinates are
already available, downstream ContextLinkr functions will allow users to
skip geocoding and proceed directly to geographic and contextual linkage
steps.

## Census tract identification example

`id_tract()` identifies the Census tract containing each coordinate
pair.

``` r
dc_test <- tibble::tibble(
  id = 1,
  latitude = 38.8977,
  longitude = -77.0365
)

dc_tract <- id_tract(
  dc_test,
  lat = latitude,
  lon = longitude,
  state = "DC"
)

dc_tract
tract_summary(dc_tract)
tract_successes(dc_tract)
tract_failures(dc_tract)
```

`state` can contain one or more states when coordinates span multiple
states.

Rows with missing latitude or longitude are retained in the output but
receive missing tract fields and `.tract_identified = FALSE`.

``` r
regional_test <- tibble::tibble(
  id = 1:2,
  latitude = c(38.8977, 39.2904),
  longitude = c(-77.0365, -76.6122)
)

regional_tracts <- id_tract(
  regional_test,
  lat = latitude,
  lon = longitude,
  state = c("DC", "MD")
)

regional_tracts
tract_summary(regional_tracts)
```

By default, `id_tract()` enables `tigris` caching during the call so
repeated tract lookups do not require repeated boundary downloads.

## Link records to Census tracts

`link_context()` provides an end-to-end wrapper for linking
individual-level records to Census tract geography. If latitude and
longitude columns are already available, `link_context()` skips
geocoding and identifies Census tracts directly.

``` r
linked <- link_context(
  sample_addresses,
  address = address,
  state = "DC",
  geocoder = "census_single",
  confirm_external = TRUE
)

linked
```

You can summarize the linked output with `link_summary()`:

``` r
link_summary(linked)
```

You can also separate successfully linked records from records that
still need review:

``` r
linked_records <- link_successes(linked)
records_to_review <- link_failures(linked)
```

These helpers are useful for basic QA after geocoding and tract
identification.

## Development roadmap

Planned core functions include:

- `gc_address()` — geocode address data.
- `id_tract()` — identify Census tracts containing coordinates.
- `get_context()` — retrieve contextual variables from Cancer InFocus.
- `link_context()` — join individual records to contextual variables
  through a wrapper workflow.
