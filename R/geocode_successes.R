#' Extract successful geocoding results
#'
#' Returns records that were successfully geocoded by [gc_address()].
#'
#' @param x A data frame returned by [gc_address()].
#'
#' @return A tibble containing rows where `.geocoded` is `TRUE`.
#'
#' @examples
#' x <- tibble::tibble(
#'   id = 1:2,
#'   latitude = c(38.9, NA_real_),
#'   longitude = c(-77.0, NA_real_),
#'   .geocoded = c(TRUE, FALSE),
#'   .geocode_input = c("components", "components")
#' )
#'
#' geocode_successes(x)
#'
#' @export
geocode_successes <- function(x) {
    check_geocode_result(x)

    filter_status(x, ".geocoded", TRUE)
}
