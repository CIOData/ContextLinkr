
# ContextLinkr

ContextLinkr is an R package for linking individual-level records to
geographic contextual data for multilevel health research.

The package currently supports address geocoding, Census tract
identification, end-to-end record linkage, and joining linked records to
user-supplied contextual datasets. Future development will add optional
retrieval of selected contextual data sources.

## Installation

``` r
# Not yet available from CRAN.
# Development installation instructions will be added after the GitHub
# repository is public.
```

## Development status

ContextLinkr is under active development. The current version supports
geocoding, Census tract identification, Cancer InFocus contextual data
retrieval, and contextual data joining workflows. Function names,
arguments, and output structures may change before a stable release.

For collaborator testing, we recommend using a tagged release or a
specific Git commit rather than relying on the moving development
branch.

## Typical workflow

ContextLinkr is designed for workflows where users start with
individual-level records and want to add place-based contextual
measures.

A typical workflow is:

1.  Start with records that contain either address fields,
    latitude/longitude coordinates, or Census tract GEOIDs.
2.  Use `link_context()` to geocode records when needed and identify
    Census tracts.
3.  Use `add_context()` to add selected Cancer InFocus contextual
    variables.
4.  Use summary helpers to review linkage and context-joining results.

``` r
linked <- link_context(
  records,
  lat = latitude,
  lon = longitude,
  state = "DC"
)

linked_with_context <- add_context(
  linked,
  measures = "Total Population"
)

link_summary(linked_with_context)
context_summary(linked_with_context)
```

For an end-to-end call, Cancer InFocus context can also be requested
directly inside `link_context()`:

``` r
linked_with_context <- link_context(
  records,
  lat = latitude,
  lon = longitude,
  state = "DC",
  include_context = TRUE,
  context_measures = "Total Population"
)
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

## Privacy and data flow

ContextLinkr is designed to keep individual-level records local except
when a user explicitly requests geocoding through an external service.

When `link_context()` or `gc_address()` uses address-based geocoding,
address fields may be sent to the selected geocoding service. For this
reason, ContextLinkr requires `confirm_external = TRUE` before address
data are sent outside the local R session.

If records already contain latitude/longitude coordinates or Census
tract GEOIDs, ContextLinkr does not need to send address fields to a
geocoder.

Cancer InFocus contextual data retrieval uses geography identifiers,
such as Census tract GEOIDs, to retrieve public contextual measures.
Users should not send names, medical record numbers, dates of birth,
street addresses, or other direct personal identifiers to Cancer InFocus
context retrieval functions.

For example, if records already contain coordinates, `link_context()`
can identify Census tracts without sending address fields to a geocoder:

``` r
linked <- link_context(
  records,
  lat = latitude,
  lon = longitude,
  state = "DC"
)
```

If records already contain tract GEOIDs, `add_context()` can retrieve
Cancer InFocus contextual variables directly:

``` r
linked_with_context <- add_context(
  records,
  tract_col = tract_geoid,
  measures = "Total Population"
)
```

## Add Cancer InFocus contextual data

ContextLinkr can add selected Cancer InFocus contextual variables to
records that have been linked to Census tracts. The recommended workflow
is to start with individual-level records, identify tract GEOIDs, and
then retrieve Cancer InFocus contextual measures for those tracts.

For an end-to-end workflow, use `link_context()` with
`include_context = TRUE`:

``` r
linked_with_context <- link_context(
  sample_addresses,
  address = address,
  state = "DC",
  geocoder = "census_single",
  confirm_external = TRUE,
  include_context = TRUE,
  context_measures = "Total Population"
)

linked_with_context
```

If records have already been linked to Census tracts, use
`add_context()`:

``` r
linked <- link_context(
  sample_addresses,
  address = address,
  state = "DC",
  geocoder = "census_single",
  confirm_external = TRUE
)

linked_with_context <- add_context(
  linked,
  tract_col = tract_geoid,
  measures = "Total Population"
)

linked_with_context
```

Available Cancer InFocus measures can be reviewed with:

``` r
available_context_measures("tract")
```

You can also search available measures by keyword:

``` r
search_context_measures("population", geography = "tract")
```

For advanced use, `get_context()` retrieves Cancer InFocus context
directly:

``` r
tract_context <- get_context(
  geographies = c("11001006202"),
  measures = "Total Population",
  geography = "tract",
  format = "wide"
)

tract_context
```

## Join contextual variables

`join_context()` is a lower-level helper for joining user-supplied
contextual data. Most users who want Cancer InFocus contextual variables
should use `add_context()` or `link_context(include_context = TRUE)`
instead.

After records have been linked to Census tract geography,
`join_context()` can join tract-level contextual variables to
individual-level records.

``` r
joined <- join_context(
  linked,
  sample_context,
  by = "tract_geoid"
)

joined
```

`join_context()` is a lower-level helper that joins already-available
contextual variables to linked individual-level records. In the intended
end-user workflow, contextual variables will come from Cancer InFocus
data. The included `sample_context` dataset is a small illustrative
dataset for examples and tests.

If the join key has different names in the linked records and contextual
data, use a named character vector. The name identifies the key in the
linked records, and the value identifies the key in the contextual data:

``` r
joined <- join_context(
  linked,
  context,
  by = c("tract_geoid" = "GEOID")
)
```

The output includes `.context_joined`, which indicates whether each
linked record matched a row in the contextual dataset.

You can summarize the context join specifically with
`context_summary()`:

``` r
context_summary(joined)
```

You can also use `link_summary()` after `join_context()` to summarize
the full workflow when geocoding, tract identification, and context join
metadata are present:

``` r
link_summary(joined)
```

You can also separate records that successfully matched contextual data
from records that still need review:

``` r
context_joined_records <- context_successes(joined)
context_records_to_review <- context_failures(joined)
```

You can also list tract GEOIDs that appear in the linked records but are
missing from the contextual data:

``` r
missing_context_keys(linked, sample_context)
```

## Context data cache

ContextLinkr caches hosted Cancer InFocus context files locally by
default to reduce repeated downloads. Users can inspect the cache
location, number of cached files, cache size, and cache modification
times with:

``` r
context_cache_info()
```

If hosted Cancer InFocus context files have been updated, or if users
want to force a fresh download, they can clear the local cache:

``` r
clear_context_cache(confirm = TRUE)
```

Users can also bypass the cache for a single context retrieval call:

``` r
get_context(
  geographies = "11001006202",
  measures = "Total Population",
  geography = "tract",
  use_cache = FALSE
)
```

Users can force a fresh download while keeping cache behavior enabled:

``` r
get_context(
  geographies = "11001006202",
  measures = "Total Population",
  geography = "tract",
  refresh_cache = TRUE
)
```

## Context data sources

ContextLinkr retrieves hosted Cancer InFocus context files from the
public ContextLinkr data endpoint. Users can inspect the hosted data
source metadata with:

``` r
context_data_sources()
```

## Context data provenance

ContextLinkr attaches lightweight provenance metadata to Cancer InFocus
context outputs. Users can inspect this metadata with:

``` r
context <- get_context(
  geographies = "11001006202",
  measures = "Total Population",
  geography = "tract"
)

context_provenance(context)
```

## Development roadmap

Implemented core functions include:

- `gc_address()` — geocode address data.
- `id_tract()` — identify Census tracts containing coordinates.
- `link_context()` — link individual-level records to Census tract
  geography.
- `join_context()` — join linked records to user-supplied contextual
  data.
- Summary and filter helpers for geocoding, tract identification,
  linkage, and contextual joins.

Planned future development includes:

- `get_context()` — retrieve contextual variable values from Cancer
  InFocus data.
- Extension of `link_context()` to support an end-to-end workflow from
  individual-level records to Cancer InFocus contextual variables.
- Additional QA helpers for reviewing incomplete geographic linkage and
  context retrieval.
