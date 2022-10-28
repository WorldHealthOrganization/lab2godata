#' Create new cases in Go.Data from lab results
#'
#' @author Amy Mikhail, \email{amy.mikhail@@gmail.com}
#'
#' @description
#' This function creates new case records in Go.Data from personal identifying
#' columns in laboratory results data.  This function can be useful when a lab
#' result is the first type of case notification received in an outbreak.
#'
#' @details
#'
#' Note that Go.Data credentials with permission to create new cases are
#' required to run this function (read permission will not be sufficient).
#'
#' The following columns are required from laboratory data:
#'   + First name
#'   + Last name
#'   + Date of birth or Age in years
#'   + Specimen collection date*
#'
#' *Specimen collection date is used as a proxy for onset date with a comment
#' to review and amend once a case investigation interview has been completed.
#'
#' **Attention:**
#' This function will first check if each case already exists in the data,
#' using `match_cases()`, however there is a small risk of creating
#' duplicates as unlike other functions in this package, the Go.Data database
#' is modified and cases are added directly to it.  It is advisable not to
#' create new cases from lab data unless you are sure that lab results always
#' come first (before a case investigation form is completed) in your workflow.
#'
#' @md
#'
#' @param url URL (web address) for Go.Data instance
#' @param username User email address used to log in to Go.Data
#' @param password User password used to log in to Go.Data
#' @param outbreak Outbreak to use; "active" (default) or other outbreak ID
#' @param labdata Name of lab results data to derive case columns from
#' @param matchcols Patient ID cols; one of 'names & dob' or 'names & age'
#' @param firstnamecol Name of lab data column containing patient first names
#' @param lastnamecol Name of lab data column containing patient last names
#' @param dobcol Name of lab data column containing patient birth dates
#' @param agecol Name of lab data column containing patient age in years
#' @param specdatecol Name of lab data column containing specimen dates
#'
#' @return
#' Printed message with number of cases created in Go.Data
#'
#' @import godataR
#' @import lubridate
#' @import jsonlite
#' @import httr
#' @import dplyr
#' @import tidyr
#' @import purrr
#'
#' @examples
#' \dontrun{
#' # Create new cases in Go.Data from lab results:
#' newcases <- create_cases(url = url,
#'                          username = username,
#'                          password = password,
#'                          outbreak = "active",
#'                          labdata = mylabresults,
#'                          matchcols = "names & dob",
#'                          firstnamecol = "firstname"
#'                          lastnamecol = "surname",
#'                          dobcol = "birthdate",
#'                          specdatecol = "sample_date")
#'
#' # View message to see if cases were created:
#' newcases
#'
#' }
#' @export
create_cases <- function(url,
                         username,
                         password,
                         outbreak = "active",
                         labdata,
                         matchcols = c("names & dob", "names & age"),
                         firstnamecol,
                         lastnamecol,
                         dobcol = NULL,
                         agecol = NULL,
                         specdatecol){


  ####################################
  # 00. Set and check parameters:
  ####################################

  # Check if requisite arguments are supplied, exit with an error if not:
  if(matchcols == "names & dob" & (is.null(dobcol))){

    stop("The name of the column containing dates of birth is missing.
         Please supply the dobcol argument to create cases by names & dob.")

  } else if(matchcols == "names & age" & (is.null(agecol))){

    stop("The name of the column containing age in years is missing.
         Please supply the agecol argument to create cases by names & age.")

  }

  # Create list of lab data columns to use in case creation:
  if(matchcols == "names & dob"){

    cols2use = c(firstnamecol, lastnamecol, dobcol, specdatecol)

  } else if(matchcols == "names & age"){

    cols2use = c(firstnamecol, lastnamecol, agecol, specdatecol)

  }

  # Create Go.Data column names to use in export:
  if(matchcols == "names & dob"){

    godatacols = c("firstName", "lastName", "dob", "dateOfOnset")

  } else if(matchcols == "names & age"){

    godatacols = c("firstName", "lastName", "age.years", "dateOfOnset")

  }

  # Check if password needs converting from raw bytes:
  if(is.raw(password)){password = rawToChar(password)}


  ####################################
  # 01. Define date ranges:
  ####################################

  # Get min and max dates from specimen collection dates:
  daterange = godataR::get_date_range(dates = labdata[, get(specdatecol)])


  ####################################
  # 02. Get cases to match on:
  ####################################

  # Import case data from Go.Data within date range:
  caselookup = godataR::get_cases_epiwindow(url = url,
                                            username = username,
                                            password = password,
                                            outbreak = "active",
                                            cols2return = "identifiers",
                                            datequery = "date range",
                                            daterangeformat = "ymd",
                                            epiwindow = 30,
                                            mindate = daterange$mindate,
                                            maxdate = daterange$maxdate)

  ####################################
  # 03. Check matches in Go.Data:
  ####################################

  if(matchcols == "names & dob"){

    # Check if cases in lab data have already been created in Go.Data:
    gdmatches = match_cases(basedata = labdata,
                            lookuptable = caselookup,
                            epiwindow = 30,
                            matchcols = matchcols,
                            firstnamecol = firstnamecol,
                            lastnamecol = lastnamecol,
                            dobcol = dobcol,
                            basedatecol = specdatecol,
                            method = "fuzzy",
                            reason = "link new")$match_report

  } else if(matchcols == "names & age"){

    # Check if cases in lab data have already been created in Go.Data:
    gdmatches = match_cases(basedata = labdata,
                            lookuptable = caselookup,
                            epiwindow = 30,
                            matchcols = matchcols,
                            firstnamecol = firstnamecol,
                            lastnamecol = lastnamecol,
                            agecol = agecol,
                            basedatecol = specdatecol,
                            method = "fuzzy",
                            reason = "link new")$match_report


  }

  ####################################
  # 04. Create case table to export:
  ####################################


  # Function to create unique case IDs on the fly:
  create_id <- function(username, lastName){

    dt = data.table::data.table(lastName = lastName)

    # Get first two letters of username:
    dt[, user_initials := toupper(stringr::str_sub(username,
                                                   start = 1,
                                                   end = 2))]

    # Get formatted date-time stamp:
    dt[, dtstamp := format(Sys.time(), format = "%y%m%d%H%M")]

    # Get first two letters of patient last name:
    dt[, case_initials := toupper(stringr::str_sub(lastName,
                                                   start = 1,
                                                   end = 2))]

    # Create new column with padded row index:
    dt[, index := formatC(.I, width = 4, format = "d", flag = "0")]

    # Create final visualId number:
    dt[, visualId := paste0(user_initials,
                            dtstamp,
                            "_",
                            case_initials,
                            index)]

    # Return data.table with new column:
    return(dt$visualId)

  }


  # Create case data set:
  cases2create = gdmatches %>%

    # Limit data to non-matched cases:
    dplyr::filter(match_id == "no match") %>%

    # Select columns to export:
    dplyr::select(all_of(cols2use)) %>%

    # Rename columns to match Go.Data column names:
    dplyr::rename_with(.fn = ~ godatacols,
                       .cols = all_of(cols2use)) %>%

    # Create unique Go.Data visual Id on the fly:
    dplyr::mutate(visualId = create_id(username = username,
                                       lastName = lastName)) %>%

    # Add column containing report date:
    dplyr::mutate(dateOfReporting = Sys.Date()) %>%

    # Convert date columns to mongodb format:
    dplyr::mutate(across(.cols = c(starts_with("date"), dob),
                         .fns = godataR::mongify_date,
                         dateformat = "ymd")) %>%

    # Add column containing type of person:
    dplyr::mutate(type = "case") %>%

    # Add column containing comment about onset dates:
    dplyr::mutate(dateRanges.comments =
                    "Onset date is from specimen date; please update")



  ####################################
  # 05. Create json query:
  ####################################


  # Convert the query to json:
  query_json <- jsonlite::toJSON(x = cases2create,
                                 # Do not indent or space out elements
                                 pretty = FALSE,
                                 # Do not enclose single values in square braces
                                 auto_unbox = TRUE)


  ####################################
  # 06. Get active outbreak ID:
  ####################################

  if(outbreak == "active"){

    # Get the active outbreak ID:
    outbreak_id = get_active_outbreak(url = url,
                                      username = username,
                                      password = password)

  } else {

    # Set outbreak ID to that supplied by user:
    outbreak_id = outbreak

  }


  ####################################
  # 07. Send query to Go.Data:
  ####################################

  # Create the case export request and fetch the export log ID:
  elid = httr::POST(url =

                      # Construct request API URL:
                      paste0(url,
                             "api/outbreaks/",
                             outbreak_id,
                             "/cases?access_token=",
                             get_access_token(url = url,
                                              username = username,
                                              password = password)),
                    # Set the content type:
                    httr::content_type_json(),

                    # Add query:
                    body = query_json,
                    encode = "raw") %>%

    # Fetch content:
    httr::content() %>%

    # Extract export log ID from content:
    purrr::pluck("exportLogId")


  ####################################
  # 05. Wait for download to compile:
  ####################################

  # Check status of request periodically, until finished
  er_status = httr::GET(paste0(url,
                               "api/export-logs/",
                               elid,
                               "?access_token=",
                               get_access_token(url = url,
                                                username = username,
                                                password = password))) %>%
    # Extract content:
    content()

  # Subset content to extract necessary messages:
  er_status = er_status[c("statusStep",
                          "totalNo",
                          "processedNo")]

  # Set waiting time to allow download to complete:
  while(er_status$statusStep != "LNG_STATUS_STEP_EXPORT_FINISHED") {

    # Wait for request to complete:
    Sys.sleep(2)

    # Get export request status again:
    er_status = httr::GET(paste0(url,
                                 "api/export-logs/",
                                 elid,
                                 "?access_token=",
                                 get_access_token(url = url,
                                                  username = username,
                                                  password = password))) %>%
      # Extract content again:
      content()

    # Set user progress message:
    message(paste0("...processed ",
                   er_status$processedNo,
                   " of ",
                   er_status$totalNo, " records"))

  }

  ####################################
  # 06. Fetch query results:
  ####################################

  # Now import query results to R using export log ID from the previous step:
  cases = httr::GET(url =
                      paste0(url,
                             "api/export-logs/",
                             elid,
                             "/download?access_token=",
                             get_access_token(url = url,
                                              username = username,
                                              password = password))) %>%

    # Fetch content of downloaded file:
    httr::content("text", encoding = "UTF-8") %>%

    # Convert json to flat data.frame:
    jsonlite::fromJSON(flatten = TRUE)

  #################################
  # Tidy up output table:

  # Check that at least one record is returned, format if so:
  if(!purrr::is_empty(cases) & is.data.frame(cases)){

    cases = cases %>%

      # Replace any NULL values with NA:
      dplyr::mutate(across(.cols = everything(),
                           .fns = null2na)) %>%

      # Unnest nested variables:
      tidyr::unnest(cols = documents,
                    names_sep = "_",
                    keep_empty = TRUE) %>%

      # Convert date columns from mongodb format to R POSIXct:
      dplyr::mutate(across(.cols = c(starts_with("date"), "dob"),
                           .fns = lubridate::ymd_hms)) %>%

      # Remove language token from person type:
      dplyr::mutate(type = tolower(gsub(
        pattern = "LNG_REFERENCE_DATA_CATEGORY_PERSON_TYPE_",
        replacement = "",
        x = type))) %>%

      # Rename columns:
      dplyr::rename_with( ~ gsub(pattern = ".",
                                 replacement = "_",
                                 x = .x,
                                 fixed = TRUE))

    # Check if documents_number col is present and rename column otherwise:
    if("documents" %in% names(cases)){

      cases = cases %>%

        dplyr::rename(documents_number = documents)

    }

    # List of column names in final order:
    colorder <- c("_id",
                  "visualId",
                  "firstName",
                  "lastName",
                  "dob",
                  "age_years",
                  "documents_number",
                  "dateOfReporting",
                  "dateOfOnset",
                  "type")

    # Update order of columns:
    cases = cases %>%

      dplyr::mutate(documents_number = as.character(documents_number)) %>%

      dplyr::relocate(all_of(colorder))

  } else {

    cases = "no matches"

  }



  ####################################
  # 07. Return cases to match on:
  ####################################

  # Return data.frame of filtered cases:
  return(cases)

}
