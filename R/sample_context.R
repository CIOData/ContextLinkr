#' Example tract-level contextual data
#'
#' A small example dataset containing tract-level contextual variables for use
#' in examples and tests. The values are illustrative and are not intended for
#' analysis.
#'
#' @format A tibble with 2 rows and 5 columns:
#' \describe{
#'   \item{tract_geoid}{Census tract GEOID.}
#'   \item{deprivation_index}{Illustrative deprivation index.}
#'   \item{rurality}{Illustrative rural/urban classification.}
#'   \item{median_household_income}{Illustrative median household income.}
#'   \item{pct_uninsured}{Illustrative percentage uninsured.}
#' }
#'
#' @examples
#' sample_context
#'
#' linked <- tibble::tibble(
#'   id = 1:2,
#'   tract_geoid = c("11001980000", "24510040100")
#' )
#'
#' join_context(linked, sample_context)
"sample_context"
