# ------------------------------------ Explore Page --------------------------------------------

tabPanel(title=list(icon("binoculars"), "Explore"),
         
         titlePanel("Explore Results"),
         
         fluidRow(
           column(6,
                  
                  fluidRow(
                    column(6,
                           selectInput("study", h5("Select Study"),  # allow user to select study
                                       choices = list("GSE101409", "GSE154345", "GSE154346","GSE181889", "GSE191054"),
                                       selected="GSE101409")),
                    column(6,
                           helpText("Select conditions to analyse within the selected study"),
                           selectInput("comparison", h4("Select Comparison"),  # allow user to select the comparisons to look at within a study. The options will be updated from NULL to the right ones when the study is selected (see app.R)
                                       choices = NULL))
                  ),
                  
                  fluidRow(
                    column(3, align="center",
                           numericInput("FC",
                                        h5("Select logFC threshold"),  # allow user to log2FC threshold value
                                        value=1)),
                    
                    column(3, align="center",
                           numericInput("FDR",   
                                        h5("Select FDR threshold"),   # allow user to FDR threshold value
                                        value=0.05)),
                    
                  ),
                  
                  br(),
                  fluidRow(
                    column(4,
                           titlePanel(h3("Result Table")),
                           helpText("RNA-sequencing analysis results")),
                    column(4,
                           div(tags$label(), style = "margin-bottom: 5px"),
                           div(downloadButton('downloadResultTable', 'Download', class = "btn-primary")),
                           helpText("Download Result Table in .tsv format"),
                           
                           tags$script(
                             "var downloadTimeout;
           $(document).on('click', '#downloadResultTable', function(){
             $('#downloadResultTable').removeClass('btn-primary').addClass('btn-success');
             var timeoutSeconds = input$study == 'GSE154416' ? 38 : 10;
             downloadTimeout = setTimeout(function(){
               $('#downloadResultTable').removeClass('btn-success').addClass('btn-primary');
             }, timeoutSeconds * 1000); // Change the button back to blue after the specified seconds
           });
           $(document).ajaxComplete(function(event, xhr, settings) {
             clearTimeout(downloadTimeout); // Clear the timeout when the download is complete
             $('#downloadResultTable').removeClass('btn-success').addClass('btn-primary');
           });
           ")
                    )
                    
                  ),
                  fluidRow(
                    column(11,
                           DT::dataTableOutput("table") %>% withSpinner(color="#0dc5c1"))  # main table on the left hand side of Explore Tab
                  ),
                  
           ), # end column
           
           column(6,
                  tabsetPanel(
                    tabPanel("Volcano Plot", h3("Volcano Plot"),
                             helpText("Volcano plot showing DEGs from the selected study and comparison" 
                             ),
                             br(),
                             br(),
                             
                             fluidRow(
                               column(1,
                                      hidden(selectInput("gene", "Select a gene from the table:", choices = NULL))),  # this will allow user to select a specific row form the table (choices updated in app.R)
                               
                               column(10, align = "right",
                                      div(tableOutput("summary_table"), style="font-size:80%"))  # count matrix on the right had side of volcanoPlot tab which shows number of up-and down-regulated genes in selected study and comparison
                             ),
                             
                             br(),
                             br(),
                             fluidRow(
                               column(11, offset=1,
                                      plotOutput("volcano") %>% withSpinner(color="#0dc5c1"))
                             ),
                             
                             br(),
                             br(),
                             
                    ),
                    
                    # heatmap (can choose between displaying lncRNAs or protein-coding genes) 
                    
                    tabPanel("Heatmap", h3("Heatmap"),
                             helpText("Heatmap of DEGs from the selected study and comparison. CPM were used to generate the plot"),
                             br(),
                             br(),
                             radioButtons("gene_type2", 
                                          h5("Select gene type"),
                                          choices = list("lncRNA genes", "Protein-coding genes"),
                                          selected="lncRNA genes"),
                             br(),
                             fluidRow(
                               column(11, offset = 1, 
                                      plotOutput("heatmap"))
                             )
                    ),
                    
                    # Gene ontology plot (can choose between up-regulated or down-regulated genes)
                    
                    tabPanel("GO Analysis", h3("Gene Ontology Analysis"),
                             helpText("Perform Gene Ontology overepresentation test using gprofiler2. FDR was used for multiple tesing correction."),
                             
                             fluidRow(
                               column(6,
                                      radioButtons("expression", 
                                                   h5("Select expression pattern"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               
                             ),
                             
                             fluidRow(
                               column(12,
                                      plotOutput("GO")  %>% withSpinner(color="#0dc5c1")),
                             ),
                             
                             br(),
                             br(),
                             
                             fluidRow(
                               column(10, offset=1,
                                      DT::dataTableOutput("GO_table") %>% withSpinner(color="#0dc5c1"))
                             )
                    ),
                    
                    
                    # Pathway analysis (can choose between up-regulated or down-regulated genes)
                    
                    tabPanel("Pathway Analysis", h3("KEGG Pathway Analysis"),
                             helpText("Perform Over-representation KEGG Pathway analysis using clusterProfiler. Shows 20 top results"),
                             
                             fluidRow(
                               column(6,
                                      radioButtons("expression2", 
                                                   h5("Select expression pattern"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               
                             ),
                             
                             plotOutput("KEGG") %>% withSpinner(color="#0dc5c1")
                    ),
                    
                    # Venn Diagram (can choose between up-regulated or down-regulated genes)
                    
                    tabPanel("Comparisons Intersection", h3("Shared DEGs among comparisons"),
                             helpText("Shows DEGs shared among the different comparisons of one study"),
                             
                             fluidRow(
                               column(6,
                                      radioButtons("expression3", 
                                                   h5("Select expression pattern"),
                                                   choices = list("up-regulated genes", "down-regulated genes"),
                                                   selected="up-regulated genes")),
                               
                             ),
                             
                             fluidRow(
                               column(10, offset=1, 
                                      plotOutput("VENN") %>% withSpinner(color="#0dc5c1"))
                             ),
                             
                             br(),
                             
                             fluidRow(
                               column(9, offset=3,
                                      hidden(p("Shared genes", id="title")),
                                      verbatimTextOutput("VENN_info", placeholder = F),
                                      tags$head(tags$style(HTML("#VENN_info{overflow-y:scroll;
                                                                  height: 100px;
                                                                  width: 450px;
                                                                  max-width: 100%;
                                                                  white-space: pre-wrap;
                                                                  padding: 10ps 12 px;}")))
                                      
                                      
                               )
                             ),
                             
                             
                             fluidRow(
                               column(5, offset=1,
                                      conditionalPanel(
                                        condition = "input.study == 'GSE101409'",
                                        hidden(p("Shared genes", id="title1")),
                                        # div(style = "margin-top: -20px"),
                                        tags$div(id="txt1", "Cytosol/Nuclear Control vs Whole Cell Control", style = "margin-top: -15px; font-size:70%"),
                                        verbatimTextOutput("VENN_info1", placeholder = F),
                                        tags$head(tags$style(HTML("#VENN_info1{overflow-y:scroll;
                                                                  height: 100px;
                                                                  width: 300px;
                                                                  max-width: 100%;
                                                                  white-space: pre-wrap;
                                                                  padding: 10ps 12 px;}")))
                                      )
                                      
                               ),
                               column(5,
                                      conditionalPanel(
                                        condition = "input.study == 'GSE101409'",
                                        hidden(p("Shared genes", id="title2")),
                                        # div(style = "margin-top: -15px"),
                                        tags$div(id="txt2", "Cytosol/Nuclear LPS vs Whole Cell LPS", style = "margin-top: -15px; font-size:70%"),
                                        verbatimTextOutput("VENN_info2", placeholder = F),
                                        tags$head(tags$style(HTML("#VENN_info2{overflow-y:scroll;
                                                                  height: 100px;
                                                                  width: 300px;
                                                                  max-width: 100%;
                                                                  white-space: pre-wrap;
                                                                  padding: 10ps 12 px;}")))
                                      )
                                      
                               ),
                             ),
                             
                             
                             br(),
                             hidden(p("Only one comparison in this study. No intersection available",
                                      id = "p_onecomparison",
                                      style = "color:black; text-align: center; position: absolute; top: 50%; left: 75%; transform: translate(-50%, -25%);")
                             )
                             
                    )
                    
                  ) # end tabsetPanel
                  
           ) # end column
         ) # end fluidRow 
         
)