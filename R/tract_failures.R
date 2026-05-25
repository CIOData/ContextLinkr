#' Extract failed Census tract identification results
#'
#' Returns records that were not assigned to Census tracts by [id_tract()].
#'
#' @param x A data frame returned by [id_tract()].
#'
#' @return A tibble containing rows where `.tract_identified` is `FALSE`.
#'
#' @examples
#' x <- tibble::tibble(
#'   id = 1:3,
#'   tract_geoid = c("11001980000", NA_character_, "11001006202"),
#'   .tract_identified = c(TRUE, FALSE, TRUE),
#'   .tract_state_fips = c("11", "11", "11"),
#'   .tract_year = c(2020, 2020, 2020)
#' )
#'
#' tract_failures(x)
#'
#' @export
tract_failures <- function(x) {
    check_tract_result(x)

    filter_status(x, ".tract_identified", FALSE)
}
