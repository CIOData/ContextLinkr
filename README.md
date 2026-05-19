
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
```

Users working with protected, sensitive, or restricted data should
geocode only in approved computing environments. If coordinates are
already available, downstream ContextLinkr functions will allow users to
skip geocoding and proceed directly to geographic and contextual linkage
steps.

## Development roadmap

Planned core functions include:

- `gc_address()` — geocode address data.
- `id_tract()` — identify Census tracts containing coordinates.
- `get_context()` — retrieve contextual variables from Cancer InFocus.
- `link_context()` — join individual records to contextual variables
  through a wrapper workflow.
