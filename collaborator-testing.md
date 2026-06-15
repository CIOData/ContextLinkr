# ContextLinkr collaborator testing guide

ContextLinkr is under active development. This guide provides a short workflow
for collaborators to test installation, linkage, and Cancer InFocus contextual
data retrieval.

## 1. Install ContextLinkr from GitHub

Install the development version from GitHub:

```r
install.packages("remotes")

remotes::install_github("CIOData/ContextLinkr")
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
