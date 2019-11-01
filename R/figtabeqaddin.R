#' Invoke RStudio add-in to help insert either figure, table or equation references
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
#' @return Inserts selected figure, table or equation reference at current location.
#'
#' @examples
#' \dontrun{
#'  insert_figtabeqref()
#' }
#'
#' @import miniUI
#' @import shiny
#' @export
#'
insert_figtabeqref <- function() {

  collect_refs <- function(lines, pattern) {
    refs <- sapply(regmatches(lines, regexec(pattern, lines)), "[", 2)
    refs <- refs[!is.na(refs)]
    return(refs)
  }

  # pattern to match ```{r fig-name} or ```{r fig-name, options}
  # for chunk names
  figtab_pattern <- "\\{r ([A-z0-9-]+)[,|\\}]"
  # pattern to match \#eq:name in LaTeX mathematical equations
  eq_pattern <- "\\#eq:([A-z]+)"

  # collect info from active document
  content <- rstudioapi::getActiveDocumentContext()
  # listfiles in the same directory
  directory = dirname(content$path)
  Rmd_files = list.files(directory, pattern = ".Rmd")

  # read all files in
  all_lines = lapply(Rmd_files, function(x) {
    readLines(paste(directory, x, sep = "/"))
    })
  # collapse to single vector
  all_lines = do.call(`c`, all_lines)
  # find all chunks
  chunks <- collect_refs(all_lines, figtab_pattern)
  # find all equations that are labelled
  eqs <- collect_refs(all_lines, eq_pattern)

  # ui
  ui <- miniPage(
    gadgetTitleBar("Add Bookdown References"),
    miniContentPanel(
      fillRow(
        radioButtons("fig_tab_eq",
                     label = "Type of Reference to Insert",
                     choices = c("Figure", "Table", "Equation")),
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
      if(input$fig_or_eq == "Equation") {
        updateSelectInput(session, "ref_to_insert",
                          label = "Select an equation reference",
                          choices = eqs)
      } else {
        updateSelectInput(session, "ref_to_insert",
                          label = "Select a chunk name",
                          choices = chunks)
      }
    })


    # Insert correct reference on "Done"
    observeEvent(input$done, {
      if(input$fig_tab_eq == "Figure") {
        ref_label <- paste0("\\@ref(fig:", input$ref_to_insert, ")")
      } else if(input$fig_tab_eq == "Table") {
        ref_label <- paste0("\\@ref(tab:", input$ref_to_insert, ")")
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
