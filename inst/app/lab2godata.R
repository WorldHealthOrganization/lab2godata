##########################################################
# Shiny app interface for the lab2godata_wrapper function
##########################################################

# Load libraries:
library(rio)
library(dplyr)
library(shiny)
library(shinyjs)
library(shinyvalidate)

# Load lab2godata settings if file is available:
if(file.exists("lab2godata_settings.rda")){

  load("lab2godata_settings.rda")

}


# List of matchcols choices with first name and surname:
namecols <- c("names & dob", "names & age", "names")

# Function to check if columns are in date format:
is.Date <- function(x) {
  inherits(x, c("Date", "POSIXt"))
}


##########################################################
# Create shiny page for inputting function arguments:

ui <- function(request){

  fluidPage(

    # Use Shiny JS:
    shinyjs::useShinyjs(),

    ###########################################################################
    # ADD GO.DATA ICON TO APP:

    # Add title panel and Go.Data logo:
    titlePanel(div(img(src = "godataR_logo.png",
                       height = '15%',
                       width = '15%'),
                   "Lab2GoData")),

    ###########################################################################
    # USER INPUTS:

    h3(),
    hr(),

    sidebarLayout(

      sidebarPanel(

        # Ask user to select the type of Go.Data installation:
        radioButtons(inputId = "godata_setup",
                     label = "Type of Go.Data installation:",
                     choices = list("Server" = "server",
                                    "Local computer" = "local"),
                     selected = ifelse(exists("godata_setup"),
                                       godata_setup,
                                       character(0)),
                     inline = FALSE,
                     width = NULL),

        # Ask user for Go.Data URL:
        shinyjs::hidden(
          textInput(inputId = "godata_url",
                    label = "Go.Data URL:",
                    value = ifelse(exists("godata_url"),
                                   godata_url,
                                   ""),
                    width = "100%",
                    placeholder = "Enter web address of your Go.Data server")),

        # Ask user for their Go.Data user name (email):
        textInput(inputId = "godata_username",
                  label = "Go.Data user name:",
                  value = "",
                  width = '100%',
                  placeholder = "Your Go.Data login email address"),

        # Ask user for their Go.Data password:
        passwordInput(inputId = "godata_password",
                      label = "Go.Data password:",
                      value = "",
                      width = NULL,
                      placeholder = "Your Go.Data password"),

        # Ask user to select the type of Go.Data installation:
        radioButtons(inputId = "labdata_type",
                     label = "What do you want to do?",
                     choices = list("Create new lab records in Go.Data" = "link new",
                                    "Edit Go.Data lab records with revised values" = "edit lab",
                                    "Update Go.Data lab records with new sequencing results" = "add sequencing"),
                     selected = ifelse(exists("labdata_type"),
                                       labdata_type,
                                       character(0)),
                     inline = FALSE,
                     width = '100%'),

        # Ask user to select the type of date query they want to use:
        radioButtons(inputId = "date_format",
                     label = "What order are your sample dates in?",
                     choices = list("Year, then month, then day" = "ymd",
                                    "Day, then month, then year" = "dmy",
                                    "Month, then day, then year" = "mdy"),
                     selected = ifelse(exists("date_format"),
                                       date_format,
                                       "ymd"),
                     inline = FALSE,
                     width = '100%'),

        # Ask user to select the epiwindow in days:
        sliderInput(inputId = "epiwindow",
                    label = "Select epiwindow for matching records:",
                    min = 10,
                    max = 90,
                    value = ifelse(exists("epiwindow"),
                                   epiwindow,
                                   30),
                    step = 5,
                    width = "100%"),

        # Ask user to select which method they want to use for matching:
        radioButtons(inputId = "matchmethod",
                     label = "How would you like to match lab records?",
                     choices = list("Use exact matches" = "exact",
                                    "Use fuzzy matching" = "fuzzy"),
                     selected = ifelse(exists("matchmethod"),
                                       matchmethod,
                                       character(0)),
                     inline = FALSE,
                     width = '100%'),

        # Ask user to select which lab results columns they want to use for matching:
        radioButtons(inputId = "matchcols",
                     label = "Which columns would you like to match on?",
                     choices = list("First name, surname and date of birth" = "names & dob",
                                    "First name, surname and age in years" = "names & age",
                                    "First name and surname" = "names",
                                    "Personal Identity Number" = "doc ID"),
                     selected = ifelse(exists("matchcols"),
                                       matchcols,
                                       character(0)),
                     inline = FALSE,
                     width = '100%'),

        # Ask user to upload their lab data file to the Shiny app:
        fileInput(inputId = "labdata_filepath",
                  label = "Browse and upload lab results file:",
                  multiple = FALSE,
                  accept = c("text/csv",
                             "text/comma-separated-values",
                             "text/plain",
                             ".csv",
                             ".txt",
                             ".xls",
                             ".xlsx")),

        # Ask user to select the column in labdata that contains sample dates:
        shinyjs::hidden(
          selectInput(inputId = "labdata_sdatecol",
                      label = "Select column containing sample dates",
                      choices = "")),


        # Ask user for Go.Data URL conditional on them choosing "server":
        shinyjs::hidden(
          selectInput(inputId = "labdata_firstnamecol",
                      label = "Select column containing first names:",
                      choices = "")),

        # Ask user for Go.Data URL conditional on them choosing "server":
        shinyjs::hidden(
          selectInput(inputId = "labdata_lastnamecol",
                      label = "Select column containing last names:",
                      choices = "")),

        # Ask user for Go.Data URL conditional on them choosing "server":
        shinyjs::hidden(
          selectInput(inputId = "labdata_dobcol",
                      label = "Select column containing dates of birth:",
                      choices = "")),

        # Ask user for Go.Data URL conditional on them choosing "server":
        shinyjs::hidden(
          selectInput(inputId = "labdata_agecol",
                      label = "Select column containing age in years:",
                      choices = "")),

        # Ask user for Go.Data URL conditional on them choosing "server":
        shinyjs::hidden(
          selectInput(inputId = "labdata_docidcol",
                      label = "Select column containing personal identity numbers:",
                      choices = "")),

        fluidRow(
          align = "left",
          br(),
          column(12,
                 splitLayout(cellWidths = c("50%", "50%"),

                             # Create submit button:
                             actionButton(inputId = "submit",
                                          label = HTML("<b>Submit parameters</b>"),
                                          width = '100%',
                                          style = 'display:left-align',
                                          class = "btn-success"),

                             # Save input parameters to use in later sessions:
                             actionButton(inputId = "saveparams",
                                          label = HTML("<b>Save parameters</b>"),
                                          width = '100%',
                                          style = 'display:left-align',
                                          class = "btn-info"),

                             ))),

        ###################################################################
        # LAB2GODATA OUTPUTS:

        # Download button for match report:
        shinyjs::hidden(downloadButton(outputId = "dl_matchreport",
                                       label = "Download match report",
                                       width = '50%',
                                       style = 'display:left-align',
                                       class = 'btn-primary')),

        # Download button for matched data:
        shinyjs::hidden(downloadButton(outputId = "dl_matchdata",
                                       label = "Download match data",
                                       width = '50%',
                                       style = 'display:left-align',
                                       class = 'btn-primary'))


      ),

      mainPanel(

        tabsetPanel(

          # Add viewer for summary table of successful matches:
          tabPanel(title = "Match summary",
                   dataTableOutput(outputId = "matchsummary")),


          # Add viewer for more detailed match report linelist:
          tabPanel(title = "Match report linelist",
                   dataTableOutput(outputId = "shortreport"))

        )

      )

    )

  )


}

##########################################################
# Run the lab2godata_wrapper function with shiny inputs:

server <- function(input, output, session) {

  #########################################################################
  # CONDITIONALLY SHOW URL:

  # Make Go.Data URL question appear conditionally on user selecting "server":
  observeEvent(input$godata_setup, {

    shinyjs::toggle(id = "godata_url",
                    condition = input$godata_setup == "server")

  })


  #########################################################################
  # INPUT VALIDATIONS:

  # Check that user has given valid Go.Data URL and username (email):
  iv <- shinyvalidate::InputValidator$new()
  iv$add_rule("godata_url", sv_url())
  iv$add_rule("godata_username", sv_email())
  iv$enable()


  #########################################################################
  # GET COLUMN NAMES FROM UPLOADED LAB DATA:

  # Create empty container for lab data:
  labdata <- reactiveVal()

  # Read in lab data and provide column names to select:
  observe({

    # Check that lab data has been uploaded:
    if (!is.null(input$labdata_filepath)) {

      # Import the lab data and put it in a data.frame with the rio package:
      indata <- rio::import(file = input$labdata_filepath$datapath)

      # Make the imported lab data reactive:
      labdata(indata)

      # Extract the column names to a list to select from:
      ldnames <- colnames(labdata())

      # Provide list of lab data column names to choose specimen date col from:
      updateSelectInput(session,
                        inputId = "labdata_sdatecol",
                        label = "Select column containing specimen dates:",
                        choices  = ldnames,
                        selected = if(exists("labdata_sdatecol")){
                          ifelse(labdata_sdatecol %in% ldnames,
                                 labdata_sdatecol,
                                 "")
                        } else {""} )

      # Provide list of lab data column names to choose first name col from:
      updateSelectInput(session,
                        inputId = "labdata_firstnamecol",
                        label = "Select column containing first names:",
                        choices  = ldnames,
                        selected = if(exists("labdata_firstnamecol")){
                          ifelse(labdata_firstnamecol %in% ldnames,
                                 labdata_firstnamecol,
                                 "")
                        } else {""} )

      # Provide list of lab data column names to choose last name col from:
      updateSelectInput(session,
                        inputId = "labdata_lastnamecol",
                        label = "Select column containing last names:",
                        choices  = ldnames,
                        selected = if(exists("labdata_lastnamecol")){
                          ifelse(labdata_lastnamecol %in% ldnames,
                                 labdata_lastnamecol,
                                 "")
                        } else {""} )

      # Provide list of lab data column names to choose dob col from:
      updateSelectInput(session,
                        inputId = "labdata_dobcol",
                        label = "Select column containing dates of birth:",
                        choices  = ldnames,
                        selected = if(exists("labdata_dobcol")){
                          ifelse(labdata_dobcol %in% ldnames,
                                 labdata_dobcol,
                                 "")
                        } else {""} )

      # Provide list of lab data column names to choose age col from:
      updateSelectInput(session,
                        inputId = "labdata_agecol",
                        label = "Select column containing age in years:",
                        choices  = ldnames,
                        selected = if(exists("labdata_agecol")){
                          ifelse(labdata_agecol %in% ldnames,
                                 labdata_agecol,
                                 "")
                        } else {""} )

      # Provide list of lab data column names to choose document ID col from:
      updateSelectInput(session,
                        inputId = "labdata_docidcol",
                        label = "Select column containing document ID numbers:",
                        choices  = ldnames,
                        selected = if(exists("labdata_docidcol")){
                          ifelse(labdata_docidcol %in% ldnames,
                                 labdata_docidcol,
                                 "")
                        } else {""} )

    }

  })


  #########################################################################
  # CONDITIONALLY SHOW LABDATA COLUMN NAMES TO FILL BASED ON MATCHCOLS:

  # Create conditional input for lab data columns containing first & last names:
  observeEvent(input$matchcols, {

    shinyjs::toggle(id = "labdata_sdatecol",
                    condition = input$matchcols %in% c(namecols, "doc ID"))

    shinyjs::toggle(id = "labdata_firstnamecol",
                    condition = input$matchcols %in% namecols)

    shinyjs::toggle(id = "labdata_lastnamecol",
                    condition = input$matchcols %in% namecols)

    shinyjs::toggle(id = "labdata_dobcol",
                    condition = input$matchcols == "names & dob")

    shinyjs::toggle(id = "labdata_agecol",
                    condition = input$matchcols == "names & age")

    shinyjs::toggle(id = "labdata_docidcol",
                    condition = input$matchcols == "doc ID")

  })


  #########################################################################
  # SAVE USER SETTINGS FOR FUTURE USE:

  observeEvent(input$saveparams, {

    # Name the parameters to save:
    godata_setup <- input$godata_setup
    godata_url <- input$godata_url
    labdata_type <- input$labdata_type
    date_format <- input$date_format
    epiwindow <- input$epiwindow
    matchmethod <- input$matchmethod
    matchcols <- input$matchcols
    labdata_sdatecol <- input$labdata_sdatecol
    labdata_firstnamecol <- input$labdata_firstnamecol
    labdata_lastnamecol <- input$labdata_lastnamecol
    labdata_dobcol <- input$labdata_dobcol
    labdata_agecol <- input$labdata_agecol
    labdata_docidcol <- input$labdata_docidcol

    # Save the parameters in a list object:
    save(file = "lab2godata_settings.rda",
         list = c("godata_setup",
                  "godata_url",
                  "labdata_type",
                  "date_format",
                  "epiwindow",
                  "matchmethod",
                  "matchcols",
                  "labdata_sdatecol",
                  "labdata_firstnamecol",
                  "labdata_lastnamecol",
                  "labdata_dobcol",
                  "labdata_agecol",
                  "labdata_docidcol"))
  })


  #########################################################################
  # RUN LAB2GODATA_WRAPPER FUNCTION WITH SHINY INPUTS:

  # Set url depending on Go.Data instance setup:
  url <- reactive(ifelse(test = input$godata_setup == "server",
                         yes = input$godata_url,
                         no = "http://localhost:3000/"))

  # Set rest of parameters based on input values:
  username <- reactive(input$godata_username)
  password <- reactive(input$godata_password)
  reason <- reactive(input$labdata_type)
  daterangeformat <- reactive(input$date_format)
  epiwindow <- reactive(input$epiwindow)
  method <- reactive(input$matchmethod)
  matchcols <- reactive(input$matchcols)
  basedatecol <- reactive(input$labdata_sdatecol)

  # Set conditional columns:

  # First name:
  firstnamecol <- reactive(ifelse(test = !is.null(input$labdata_firstnamecol),
                                  yes = input$labdata_firstnamecol,
                                  no = NULL))

  # Last name:
  lastnamecol <- reactive(ifelse(test = !is.null(input$labdata_lastnamecol),
                                 yes = input$labdata_lastnamecol,
                                 no = NULL))

  # Date of birth:
  dobcol <- reactive(ifelse(test = !is.null(input$labdata_dobcol),
                            yes = input$labdata_dobcol,
                            no = NULL))

  # Age in years:
  agecol <- reactive(ifelse(test = !is.null(input$labdata_agecol),
                            yes = input$labdata_agecol,
                            no = NULL))

  # Personal / document identity number:
  docidcol <- reactive(ifelse(test = !is.null(input$labdata_docidcol),
                              yes = input$labdata_docidcol,
                              no = NULL))


  ##############################################################
  # Run lab2godata function as soon as submit button is pressed:

  # Create full match report for export:
  matches <- eventReactive(input$submit, {

      # Run lab2godata_wrapper to generate matches:
      lab2godata_wrapper(
        url = url(),
        username = username(),
        password = password(),
        reason = reason(),
        daterangeformat = daterangeformat(),
        epiwindow = epiwindow(),
        method = method(),
        matchcols = matchcols(),
        labdata = labdata(),
        basedatecol = basedatecol(),
        firstnamecol = firstnamecol(),
        lastnamecol = lastnamecol(),
        dobcol = dobcol(),
        agecol = agecol(),
        docidcol = docidcol())

    })


    # Write summary table to Shiny dashboard:
    output$matchsummary <- renderDataTable({matches()$match_summary})

    # Write table to Shiny dashboard:
    output$shortreport <- renderDataTable({matches()$short_report})




  #########################################################################
  # EXPORT MATCHED LAB DATA WITH DOWNLOAD HANDLER:

    ##########################################
    # Create export file for match report:

    observe({

      if(!is.null(matches()$match_report)){

        shinyjs::show(id = "dl_matchreport")

      }

    })

    # Next add the download handler:
    output$dl_matchreport <- downloadHandler(

      filename = function(){

      # Create the file name:
      paste0("Go.Data lab match report_", Sys.Date(), ".xlsx")

    },

    content = function(file){

      # Export the data with rio::export():
      rio::export(x = matches()$match_report, file = file)

      }
  )

    ##########################################
    # Create export file for matched lab data:

    observe({

      if(!is.null(matches()$matched_data)){

        shinyjs::show(id = "dl_matchdata")

      }

    })

    # Next add the download handler:
    output$dl_matchdata <- downloadHandler(

      filename = function(){

        # Create the file name:
        paste0("Go.Data lab matched data_", Sys.Date(), ".xlsx")

        },

      content = function(file){

        # Export the data with rio::export():
        rio::export(x = matches()$matched_data, file = file)

        }

      )



    ##########################################################################
    # STOP THE APP WHEN THE SESSION ENDS:

    if (!interactive()) {
      session$onSessionEnded(function() {
      stopApp()
      q("no")
    })
  }

}


# Run app:
shinyApp(ui, server)
