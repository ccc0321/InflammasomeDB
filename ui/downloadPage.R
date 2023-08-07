# ---------------------------------- Download Page -------------------------------------

tabPanel(title=list(icon("download"),"Download"),
         titlePanel(div(HTML("Download <em>InflammasomeDB</em> Data"))),
         
         p("All data in InflammasomeDB were processed from a pipeline available in the Analysis_of_Inflammasome_Study ", tags$a(href="https://github.com/heartlncrna/Analysis_of_Inflammasome_Study", "GitHub Repository")),
         
         fluidRow(
           column(3,
                  selectInput("dataset", h5("Select a dataset"),
                              choices = c("GSE101409", "GSE154345", "GSE154346","GSE181889", "GSE191054")),  # allow user to select dataset to download
                  radioButtons("filetype", "File type:",
                               choices = c("csv", "tsv")),  # allow user to select type of file
                  
                  downloadButton('downloadData', 'Download', class="btn-primary"),
                  br(),
                  helpText("It takes around 15 seconds for the download window to appear"),
                  
           ), # end column
           
           column(9,
                  div(DT::dataTableOutput("table2"), style = "font-size: 85%; width: 90%"))
         ) # end fluidRow
         
)