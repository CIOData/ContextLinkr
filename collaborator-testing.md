# ContextLinkr collaborator testing guide

ContextLinkr is under active development. This guide provides a short workflow
for collaborators to test installation, linkage, and Cancer InFocus contextual
data retrieval.

## 1. Install ContextLinkr from GitHub

Install the development version from GitHub:

```r
install.packages("remotes")

remotes::install_github(
  "CIOData/ContextLinkr@v0.1.0-beta.2",
  upgrade = "never",
  dependencies = TRUE,
  build_vignettes = FALSE
)
```

## 2. Load the package

```r
library(ContextLinkr)
```

## 3. Confirm package help is available

```r
?link_context
?add_context
?get_context
```

## 4. Test coordinate-based tract linkage

```r
records <- tibble::tibble(
  id = 1,
  latitude = 38.8977,
  longitude = -77.0365
)

linked <- link_context(
  records,
  lat = latitude,
  lon = longitude,
  state = "DC"
)

linked
link_summary(linked)
```

## 5. Search available Cancer InFocus measures

```r
search_context_measures("population", geography = "tract")
```

## 6. Add Cancer InFocus context

```r
linked_with_context <- add_context(
  linked,
  measures = "Total Population"
)

linked_with_context
context_summary(linked_with_context)
```

## 7. Test the end-to-end workflow

```r
linked_with_context_2 <- link_context(
  records,
  lat = latitude,
  lon = longitude,
  state = "DC",
  include_context = TRUE,
  context_measures = "Total Population"
)

linked_with_context_2
context_summary(linked_with_context_2)
```

## 8. Optional address-geocoding test

Only run this section with non-sensitive test addresses. Address data may be sent
to an external geocoding service when `confirm_external = TRUE`.

```r
address_records <- tibble::tibble(
  id = 1,
  address = "1600 Pennsylvania Ave NW, Washington, DC 20500"
)

linked_from_address <- link_context(
  address_records,
  address = address,
  state = "DC",
  geocoder = "census_single",
  confirm_external = TRUE
)

linked_from_address
link_summary(linked_from_address)
```

## 9. What to report

Please report:

- installation problems;
- unclear function names or arguments;
- confusing error messages;
- slow steps;
- missing documentation;
- unexpected outputs;
- privacy or data-flow concerns.

## 10. Submit feedback

Please submit feedback using the GitHub issue template titled
"Collaborator feedback". If you encountered a reproducible error, use the
"Bug report" template instead.

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
