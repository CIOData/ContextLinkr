#' Extract failed geocoding results
#'
#' Returns records that were not successfully geocoded by [gc_address()].
#'
#' @param x A data frame returned by [gc_address()].
#'
#' @return A tibble containing rows where `.geocoded` is `FALSE`.
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
#' geocode_failures(x)
#'
#' @export
geocode_failures <- function(x) {
    check_geocode_result(x)

    filter_status(x, ".geocoded", FALSE)
}
