#' Invoke RStudio add-in to help insert either equation or figure references
#'
#' @details It is assummed that this addin will be called whilst the focus of
#'     RStudio is an R markdown document that will allow users to insert
#'     references - for example a Bookdown document.
#'
#'     It will search the R markdown document and collect all chunk names and
#'     equation references. The user can then choose what to insert.
#'
#'     When the user has chosen what to insert, they should click Done. The
#'     reference, including required syntax will be inserted at the cursor
#'     position.
#'
#' @return Inserts selected equation or figure reference at current location.
#'
#' @examples
#' \dontrun{
#'  insert_figeqref()
#' }
#'
#' @import miniUI
#' @import shiny
#' @export
#'
insert_figeqref <- function() {

  collect_refs <- function(content, pattern) {
    # look for strings line by line in R markdown document
    refs <- sapply(regmatches(content, regexec(pattern, content)), "[", 2)
    # remove NAs
    refs <- refs[!is.na(refs)]
    return(refs)
  }

  # pattern to match ```{r fig-name} or ```{r fig-name, options}
  # for chunk names
  fig_pattern <- "\\{r ([A-z]+)[,|\\}]"
  # pattern to match \#eq:name in LaTeX mathematical equations
  eq_pattern <- "\\#eq:([A-z]+)"

  # collect current R markdown document
  content <- rstudioapi::getActiveDocumentContext()$contents
  # find all chunks
  chunks <- collect_refs(content, fig_pattern)
  # find all equations that are labelled
  eqs <- collect_refs(content, eq_pattern)

  # ui
  ui <- miniPage(
    gadgetTitleBar("Add Bookdown References"),
    miniContentPanel(
      fillRow(
        radioButtons("fig_or_eq",
                     label = "Type of Reference to Insert",
                     choices = c("Figure", "Equation")),
        selectInput("ref_to_insert",
                    label = "Select a chunk name",
                    choices = chunks)
      )
    )
  )

  # server
  server <- function(input, output, session) {

    # switch dropdown to either figure or equation labels
    observeEvent(input$fig_or_eq, {
      if(input$fig_or_eq == "Figure") {
        updateSelectInput(session, "ref_to_insert",
                          label = "Select a chunk name",
                          choices = chunks)
      } else {
        updateSelectInput(session, "ref_to_insert",
                          label = "Select an equation reference",
                          choices = eqs)
      }
    })


    # Insert correct reference on "Done"
    observeEvent(input$done, {
      if(input$fig_or_eq == "Figure") {
        ref_label <- paste0("\\@ref(fig:", input$ref_to_insert, ")")
      } else {
        ref_label <- paste0("\\@ref(eq:", input$ref_to_insert, ")")
      }
      rstudioapi::insertText(ref_label)
      stopApp()
    })

    # listen for cancel
    observeEvent(input$cancel, {
      stopApp()
    })

  }

  runGadget(ui, server)
}
