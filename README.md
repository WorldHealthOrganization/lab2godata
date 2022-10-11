lab2godata: essential tools for matching lab results
================
10 October 2022

<!-- README.md is generated from README.Rmd. Please edit that file -->

## Overview

[Go.Data](https://www.who.int/tools/godata) is a software for outbreak
response and contact tracing developed by WHO in collaboration with
partners in the Global Outbreak Alert and Response Network (GOARN).
Go.Data focusses on case and contact data including laboratory data,
hospitalization and other variables collected through investigation
forms. It generates contact follow-up lists and allows visualisation of
chains of transmission.

The `lab2godata` package was built to allow the Go.Data [user
community](https://community-godata.who.int/) to easily match new
laboratory results with existing cases or lab records in Go.Data, in
order to create new Go.Data lab records or update them, respectively.
`lab2godata` has been developed with a broad user base in mind; a
central feature is the lab2godata shiny app, which can be launched from
the user’s desktop with the click of a button, or if preferred, by
running the `runlab2godata()` command within RStudio. The app provides
an intuitive interface that allows users to upload a file of laboratory
data and choose how they wish to match this data with existing Go.Data
records. Once choices are submitted, the app will produce a summary of
the successful matches and a more detailed match report line list. The
match report and a clean file of matched data ready for importing into
Go.Data are then available for download.

## Prerequisites:

As with `godataR`, users will need to have their Go.Data credentials in
order to start using the app (or the R package). The following
credentials are needed:

-   The web address of the Go.Data instance,
    e.g. `https://www.mygodataserver.com/`
-   Go.Data user name (the email address used to log in to your Go.Data
    instance)
-   Go.Data password (the password you use to access your Go.Data
    instance)

In addition to this, advanced users may wish to match labdata for an
outbreak that is not currently active; if this is the case, you will
also need the Go.Data outbreak ID. You can retrieve a list of outbreak
IDs with `godataR::get_all_outbreaks()` and your Go.Data login
credentials.

## Fetching records from Go.Data to match on:

Depending on whether the user wants to match new lab results or update
existing ones, the new `godataR` functions `get_cases_epiwindow()`,
`get_contacts_epiwindow()` and `get_labresults_epiwindow()` are used to
retrieve case, contact and laboratory records from Go.Data,
respectively. If you wish to use these functions independently of the
app, you will also need to install `godataR` in your normal R
environment.

## Matching lab data with Go.Data records:

The primary function that performs the matching is called
`match_cases()`. It has a few additional options compared to the Shiny
app, so may be useful to run from an R environment for more experienced
users. The function uses two main methods to perform matching;

-   1.  First names and surnames are converted to soundex codes and then
        compared;

-   2.  Age, dates of birth and identity card numbers are compared with
        the Damerau-Levenshtein method, allowing for a single
        transposition (except for age).

-   3.  Exact matching (with no deviations allowed) is also available.

This function was developed to address some record linkage challenges.
Currently within the Go.Data graphical user interface, it is only
possible to perform bulk uploads of new laboratory data if you also have
the Go.Data case IDs that they are linked to in the same file. Due to
variations in workflows, it is not always possible to provide Go.Data
case IDs to laboratories in advance of receiving their results.
`lab2godata` solves this problem, by matching on core patient
identifiers that are typically available in laboratory data (and are
mandatory fields in Go.Data), such as patient names and dates of birth
or age. A passport or national identity card number can also be used (so
long as it has already been entered into Go.Data). Within the app or
when using the `lab2godata_wrapper()` function from R, users can select
which combination of columns they wish to match on. The app can be quite
useful at this stage for testing out different combinations of columns
to match on and experimenting with different matching protocols. It
usually takes a few seconds for the results to appear. As long as the
app remains open, the user can modify some of their choices and run it
again, without needing to enter all the parameters from scratch.

## Limitations:

Currently, the `match_cases()` function can only work on text written in
the Roman (i.e. English language) alphabet; however methods to expand
its functionality to the other four UN languages in the first instance,
are actively being sought. Developper contributions in this area are
also welcome.

## Installation

This package is hosted on the WHO Github Repository here:
<https://github.com/WorldHealthOrganization/lab2godata>. Install the
package within your R console by executing the code below.

``` r

# Install package
devtools::install_github("WorldHealthOrganization/lab2godata")
```

In addition, a downloadable executable file will be available soon for
non R users. The file will install this package, as well as dependent
packages and R and RStudio (unless already present) on the user’s
computer. Watch this space!

## Usage

### Provide parameters (your Go.Data credentials):

You must have valid Go.Data user credentials with appropriate
roles/permissions to successfully receive an access token to make any
API calls. You can set your parameters at the outset of your R session,
to call them more easily when fetching your collections. You can also
specify ad-hoc if you are working across various outbreaks.

``` r

### Set Go.Data login credentials:

# Load libraries:
library(getPass)
library(godataR)

# Your Go.Data URL
url <- "https://MyGoDataServer.com/" 

# Your email address to log in to Go.Data
username <- getPass::getPass(msg = "Enter your Go.Data username (email address):") 

# Your password to log in to Go.Data
password <- charToRaw(getPass::getPass(msg = "Enter your Go.Data password:")) 

# Get ID for active outbreak:
outbreak_id <- godataR::get_active_outbreak(url = url, 
                                            username = username, 
                                            password = rawToChar(password))
```

… continue to add sections and screenshots here…

## API documentation:

Go.Data is running on [LoopBack](https://loopback.io/doc/index.html).
You can access the self-documenting description of all available API
methods in using Loopback Explorer by adding `/explorer` to the end of
any Go.Data URL.

You can find more information on the Go.Data API
[here](https://worldhealthorganization.github.io/godata/api-docs/).

## How to provide feedback or contribute:

Bug reports and feature requests should be posted on github under
[*issues*](https://github.com/WorldHealthOrganization/godataR/issues).
All other questions and feedback, feel free to email us at
<godata@who.int> or post a query in the [Go.Data Community of
Practice](https://community-godata.who.int/)

Contributions are welcome via pull requests.
