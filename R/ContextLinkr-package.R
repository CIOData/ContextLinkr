#' ContextLinkr: Link Individual Records to Geographic Context
#'
#' ContextLinkr provides tools for linking individual-level records to
#' geographic context. The package supports modular workflows for geocoding
#' address data, identifying Census tracts from coordinates, linking records to
#' contextual datasets, and reviewing workflow quality.
#'
#' @section Geocoding:
#' Use [gc_address()] to geocode address data when appropriate. Because address
#' data can be sensitive, external geocoding requires explicit confirmation with
#' `confirm_external = TRUE`.
#'
#' Use [geocode_summary()], [geocode_successes()], and [geocode_failures()] to
#' review geocoding results.
#'
#' @section Tract identification:
#' Use [id_tract()] to identify Census tracts from latitude and longitude.
#' This workflow can be used after geocoding or directly with pre-geocoded data.
#'
#' Use [tract_summary()], [tract_successes()], and [tract_failures()] to review
#' tract identification results.
#'
#' @section End-to-end linking:
#' Use [link_context()] as a convenience wrapper for geocoding records when
#' needed and identifying Census tracts.
#'
#' Use [link_summary()], [link_successes()], and [link_failures()] to review
#' linked outputs.
#'
#' @section Contextual data joins:
#' Use [join_context()] to join linked records to contextual datasets that are
#' already available in memory. Use [missing_context_keys()] to identify linked
#' geographic keys that are not present in a contextual dataset.
#'
#' Use [context_summary()], [context_successes()], and [context_failures()] to
#' review contextual data joins.
#'
#' @section Example data:
#' The package includes [sample_addresses] and [sample_context] as small
#' illustrative datasets for examples and tests. These datasets are not
#' intended for analysis.
#'
#' @keywords internal
"_PACKAGE"
