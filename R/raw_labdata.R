#' Line list of new lab results to match and import into Go.Data
#'
#' @author Amy Mikhail, \email{amy.mikhail@@gmail.com}
#'
#' Example line list of new lab results that need to be bulk-imported to
#' Go.Data. This data can be used as base data with `match_cases()` to
#' demonstrate how to link new lab results with existing cases in Go.Data and
#' create new lab records.  Note that this is not real data; it has been
#' created for the purpose of demonstration only.
#' @md
#'
#' @docType data
#'
#' @usage data(raw_labdata)
#'
#' @format An object of class `data.frame` and `data.table`
#'
#' @keywords datasets
#'
#' @examples
#' # Load data
#' data(raw_labdata)
#'
#' # Look at head of data set:
#' head(raw_labdata)
"raw_labdata"
