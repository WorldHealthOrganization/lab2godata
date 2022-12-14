#' Go.Data exported line list of cases with identifying columns
#'
#' @author Amy Mikhail, \email{amy.mikhail@@gmail.com}
#'
#' Example line list of cases exported from Go.Data with patient identifying
#' columns. This data can be used as a reference (look-up) table with
#' `match_cases()` to demonstrate how to link new lab results with existing
#' cases in Go.Data and create new lab records. Note that this is not real data;
#' it has been created for the purpose of demonstration only.
#' @md
#'
#' @docType data
#'
#' @usage data(gd_casedata)
#'
#' @format An object of class `data.frame` and `data.table`
#'
#' @keywords datasets
#'
#' @examples
#' # Load data
#' data(gd_casedata)
#'
#' # Look at head of data set:
#' head(gd_casedata)
"gd_casedata"
