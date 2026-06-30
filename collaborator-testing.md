# ContextLinkr collaborator testing guide

ContextLinkr is under active collaborator-beta development. This guide provides 
a short, structured workflow for testing installation, hosted Cancer InFocus context 
retrieval, context enrichment, and selected linkage helpers.

Please do **not** use real patient, participant, address-level, or otherwise identifiable 
data for beta testing. The examples below use synthetic IDs and public Census tract GEOIDs.

## 1. Install ContextLinkr from GitHub

Install the tagged collaborator-beta release from GitHub. Using the tag keeps all tester 
feedback tied to the same package snapshot.

```r
install.packages("remotes")

remotes::install_github(
  "CIOData/ContextLinkr@v0.1.0-beta.2",
  upgrade = "never",
  dependencies = TRUE,
  build_vignettes = FALSE
)
```

Load the package and confirm the installed version.

```r
library(ContextLinkr)

packageVersion("ContextLinkr")
```

## 2. Confirm package help is available

These help pages should open without errors.

```r
?link_context
?add_context
?get_context
?available_context_measures
```

## 3. Inspect source and cache information

ContextLinkr retrieves hosted Cancer InFocus contextual data and can cache downloaded 
files locally. These commands help confirm that source metadata and cache helpers are working.

```r
context_cache_info()

context_data_sources()
```

## 4. Search available Cancer InFocus measures

Use `available_context_measures()` to view the available hosted measures and 
`search_context_measures()` to find measures by keyword.

```r
measures <- available_context_measures()
head(measures)

search_context_measures("population", geography = "tract")
```

## 5. Retrieve Cancer InFocus context directly

This test retrieves hosted tract-level Cancer InFocus context for two public Census 
tract GEOIDs.

```r
test_tracts <- c("21067003600", "21067004205")

context_wide <- get_context(
  geographies = test_tracts,
  geography = "tract",
  measures = "Total Population",
  format = "wide",
  use_cache = TRUE,
  refresh_cache = FALSE
)

context_wide

nrow(context_wide)
anyDuplicated(context_wide$GEOID)
"Total Population" %in% names(context_wide)

context_provenance(context_wide)
```

Expected checks:

```r
nrow(context_wide)
# 2

anyDuplicated(context_wide$GEOID)
# 0

"Total Population" %in% names(context_wide)
# TRUE
```

## 6. Add Cancer InFocus context to synthetic records

Most users will start with individual-level records and add contextual measures 
after tract GEOIDs have been identified. This example starts with synthetic records 
that already include tract GEOIDs.

```r
records <- data.frame(
  person_id = c("test_001", "test_002"),
  tract_geoid = c("21067003600", "21067004205")
)

records_with_context <- add_context(
  .data = records,
  tract_col = "tract_geoid",
  measures = "Total Population",
  use_cache = TRUE,
  refresh_cache = FALSE
)

records_with_context

nrow(records_with_context)
anyDuplicated(records_with_context$tract_geoid)
"Total Population" %in% names(records_with_context)

context_summary(records_with_context)
context_provenance(records_with_context)
```

Expected checks:

```r
nrow(records_with_context)
# 2

anyDuplicated(records_with_context$tract_geoid)
# 0

"Total Population" %in% names(records_with_context)
# TRUE
```

## 7. Optional: test coordinate-based tract linkage

Run this optional section if you want to test tract identification from coordinates. 
The example uses public coordinates and a synthetic record ID.

```r
coordinate_records <- data.frame(
  person_id = "test_001",
  latitude = 38.8977,
  longitude = -77.0365
)

linked <- link_context(
  coordinate_records,
  lat = latitude,
  lon = longitude,
  state = "DC"
)

linked

link_summary(linked)
```

If tract linkage succeeds, you can add a small set of Cancer InFocus context measures.

```r
linked_with_context <- add_context(
  .data = linked,
  tract_col = "tract_geoid",
  measures = "Total Population",
  use_cache = TRUE,
  refresh_cache = FALSE
)

linked_with_context

context_summary(linked_with_context)
context_provenance(linked_with_context)
```

## 8. Optional: test the end-to-end linkage workflow

This optional section tests coordinate-based linkage and context retrieval in one call.

```r
linked_with_context_2 <- link_context(
  coordinate_records,
  lat = latitude,
  lon = longitude,
  state = "DC",
  include_context = TRUE,
  context_measures = "Total Population"
)

linked_with_context_2

link_summary(linked_with_context_2)
context_summary(linked_with_context_2)
context_provenance(linked_with_context_2)
```

## 9. Optional: address-geocoding test

Only run this section with non-sensitive test addresses. Address data may be sent 
to an external geocoding service when `confirm_external = TRUE`.

```r
address_records <- data.frame(
  person_id = "test_001",
  address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
)

linked_from_address <- link_context(
  address_records,
  address = address,
  geocoder = "census_single",
  confirm_external = TRUE
)

linked_from_address

link_summary(linked_from_address)
```

```r
multi_state_records <- data.frame(
  person_id = c("test_dc", "test_ky"),
  address = c(
    "1600 Pennsylvania Ave NW, Washington, DC 20500",
    "800 Rose St, Lexington, KY 40536"
  )
)

linked_multi_state <- link_context(
  multi_state_records,
  address = address,
  geocoder = "census_single",
  confirm_external = TRUE
)

linked_multi_state[, c(
  "person_id",
  "geocoded_state",
  "tract_geoid",
  ".tract_identified"
)]
```

For complete address strings, `state` is not required when the selected geocoder 
returns state information. ContextLinkr stores the inferred state in 
`geocoded_state` and uses it internally for tract lookup. For coordinate-based 
workflows, `state` is still required in the current version.

## 10. What to report

Please report:

- operating system;
- R version;
- ContextLinkr version from `packageVersion("ContextLinkr")`;
- whether installation succeeded;
- any warnings or errors;
- whether the workflow was understandable;
- whether the output was understandable;
- unclear function names or arguments;
- slow steps;
- missing documentation;
- unexpected outputs;
- privacy or data-flow concerns;
- one thing that should be improved before broader testing.

## 11. Submit feedback

Please submit feedback using the GitHub issue template titled **Collaborator feedback**.

If you encountered a reproducible error, use the **Bug report** template instead 
and include the smallest reproducible example you can share.

## Troubleshooting

If installation or context retrieval fails, please include the following in your feedback:

```r
packageVersion("ContextLinkr")
R.version.string
Sys.info()[c("sysname", "release", "machine")]

context_cache_info()
context_data_sources()
```

Common checks:

- confirm that your internet connection is active;
- confirm that your network or VPN is not blocking `cancerinfocus.org`;
- confirm that tract GEOIDs are 11-digit Census tract GEOIDs;
- use `available_context_measures()` or `search_context_measures()` to find valid measure names;
- clear and rebuild the context cache if cached files appear stale.

```r
clear_context_cache(confirm = TRUE)

get_context(
  geographies = "21067003600",
  measures = "Total Population",
  geography = "tract",
  format = "wide",
  use_cache = TRUE,
  refresh_cache = TRUE
)
```

## Validated failure paths

The collaborator-beta version has been checked for the following common user-facing issues:

- malformed tract GEOIDs;
- unsupported tract state FIPS codes;
- valid-looking tract GEOIDs with no hosted context rows;
- unknown measure names;
- empty measure searches;
- missing tract columns in `add_context()`;
- missing or blank tract IDs;
- duplicated individual records within the same tract;
- cache clearing and cache rebuild behavior;
- unsupported `format` and `geography` arguments.

If you encounter a confusing error message, please include the exact function call, 
error text, operating system, R version, and ContextLinkr version in your feedback.
