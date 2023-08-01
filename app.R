library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinycssloaders)
library(shinydashboard)

library(BiocManager)
options(repos = BiocManager::repositories())

library(ggplot2)
library(dplyr)
library(DT)
library(tibble)
library(data.table)
library(pheatmap, include.only = "pheatmap")
library(RColorBrewer, include.only = "brewer.pal")
library(tableHTML)
library(gprofiler2, include.only = c("gost", "gostplot"))
library(enrichplot)
library(clusterProfiler)
library(org.Hs.eg.db)
library(AnnotationDbi)
library(VennDiagram)
library(eulerr)
library(htmlwidgets)
library(gridExtra)


################### Helper function #############################################

footerHTML <- function() {  # defines style of the footer
  "
    <footer class='footer' style='background-color: #333333; color: white; height: 1cm; display: flex; justify-content: center; align-items: center;'>
      <div>
        <span style='margin: 0;'>InflammasomeDB © 2023 Copyright:</span>
        <a href='http://heartlncrna.github.io' target='_blank'>heartlncrna</a>
        <span>&nbsp</span>
        <a href='https://github.com/ccc0321/InflammasomeDB' target='_blank'> 
          <img src='GitHub-Mark-Light-64px.png' height='20'>
      </div>
    </footer>
  "
}


# colors used in heatmap
mypalette <- brewer.pal(11,"RdYlBu")
morecols <- colorRampPalette(mypalette)
myCol1 <- brewer.pal(4, "Pastel2")
myCol2 <- brewer.pal(3, "Pastel2")


########################################### shiny app ########################################


ui <- fluidPage(
  
  useShinyjs(),
  
  tags$head(
    tags$link(rel = "stylesheet", href = "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"),
    tags$style(  # details position of footer
      HTML("
           html {
           position: relative;
           min-height: 100%;
           }
           
           body {
           margin-bottom: 1cm;
           padding-bottom: 20px; /* add margin to the top */
           }
           
           .footer {
           position: absolute;
           bottom: 0;
           width: 100%;
           background-color: #333333;
           color: white;
           height: 1cm;
           display: flex;
           justify-content: center;;
           align-items: center;
           }
        ")
    ),
    tags$script(
      "var downloadTimeout;
           $(document).on('click', '#downloadData', function(){
             $('#downloadData').removeClass('btn-primary').addClass('btn-success');
             var timeoutSeconds = input$dataset == 'GSE154416' ? 38 : 10;
             downloadTimeout = setTimeout(function(){
               $('#downloadData').removeClass('btn-success').addClass('btn-primary');
             }, timeoutSeconds * 1000); // Change the button back to blue after the specified seconds
           });
           $(document).ajaxComplete(function(event, xhr, settings) {
             clearTimeout(downloadTimeout); // Clear the timeout when the download is complete
             $('#downloadData').removeClass('btn-success').addClass('btn-primary');
           });"
      )
  ),
  
  theme = bslib::bs_theme(bootswatch = "yeti"),
  
  navbarPage(
    "InflammasomeDB",
    
    source(file.path("ui", "homePage.R"), local=TRUE)$value,
    source(file.path("ui", "explorePage.R"), local=TRUE)$value,
    source(file.path("ui", "lncRNAPage.R"), local=TRUE)$value,
    source(file.path("ui", "downloadPage.R"), local=TRUE)$value,
    source(file.path("ui", "documentationPage.R"), local=TRUE)$value,
    
  ),# end navbarPage
  
  tags$footer(HTML(footerHTML()))
  
) # end fluidPage



server <- function(input, output, session){
   studyInput <- reactive({
    if(input$study == "GSE101409"){
      data <- data.frame(fread("data/GSE101409-All.txt"))
    } else if (input$study == "GSE154345"){
      data <- data.frame(fread("data/GSE154345-All.txt"))
    } else if (input$study == "GSE154346") {
      data <- data.frame(fread("data/GSE154346-All.txt"))
    } else if (input$study == "GSE181889"){
      data <- data.frame(fread("data/GSE181889-All.txt"))
    } else if (input$study == "GSE191054") {
      data <- data.frame(fread("data/GSE191054-All.txt"))
    }
    
    
    on.exit(rm(data))
    
    return(data)
  })
  
  
  # change the options for the "comparison" drop down menu (in ExplorePanel.R) based on the study selected in the "study" drop down menu (in ExplorePanel.R)
  comparisons <- reactive({
    if(input$study == "GSE101409"){
      c("Control_Cytosol_vs_Control_Whole_Cell",
        "Control_Nuclear_vs_Control_Whole_Cell",
        "Control_Nuclear_vs_Control_Cytosol",
        "LPS_Cytosol_vs_LPS_Whole_Cell",
        "LPS_Nuclear_vs_LPS_Whole_Cell",
        "LPS_Nuclear_vs_LPS_Cytosol")
    } else if (input$study == "GSE154345") {
      c("M1_vs_M0", 
        "M2_vs_M0",
        "M1_vs_M2",
        "M2_vs_M1")
    }else if (input$study == "GSE154346"){
      c("M1_vs_M0", 
        "M2_vs_M0",
        "M1_vs_M2",
        "M2_vs_M1")
    }  else if (input$study == "GSE181889"){
      c("ORN8L_vs_Resting",
        "CXCL4+ORN8L_vs_Resting", 
        "CXCL4_vs_Resting")
    } else if (input$study == "GSE191054") {
      c("LPS_vs_PBS", 
        "MUS_vs_PBS",
        "LPS_vs_MUS")
    }
    
  })
  
  
  observeEvent(input$study, {
    updateSelectInput(
      session,
      inputId = "comparison",
      label = "Select Comparison",
      choices = comparisons(),
      selected = comparisons()[1]
    )
  })
  
  studyInput_mutated <- reactive({
    df <- studyInput()[studyInput()$Comparison == input$comparison, ] %>%
      mutate(
        Significance = case_when(
          logFC >= input$FC & FDR < input$FDR & Biotype == "protein_coding" ~ "Up-reg protein-coding gene",
          logFC >= input$FC & FDR < input$FDR & Biotype == "lncRNA" ~ "Up-reg lncRNA",
          logFC <= -input$FC & FDR < input$FDR & Biotype == "protein_coding" ~ "Down-reg protein-coding gene",
          logFC <= -input$FC & FDR < input$FDR & Biotype == "lncRNA" ~ "Down-reg lncRNA",
          TRUE ~ "Unchanged"))
    
    
    on.exit(rm(df))
    
    return(df)
  })
 
  # allow user to select a row in table
  selected_row <- reactive({
    data.frame(Ensembl_ID = character(),
               Gene_symbol = character(),
               logFC = numeric(),
               FDR = numeric(),
               Biotype = character(),
               Significance = character())
  })
  
  observeEvent(input$table_rows_selected, {
    row_index <- input$table_rows_selected
    row_name <- studyInput_mutated()[row_index, "Gene_symbol"]
    updateSelectInput(session, "gene", choices = row_name, selected=row_name[1])  
  })
  
  selected_row <- reactive({
    row_name <- input$gene
    if (!is.null(row_name)) {
      studyInput_mutated()[studyInput_mutated()$Gene_symbol == row_name, ]
    } else {
      data.frame(Ensembl_ID = character(),
                 Gene_symbol = character(),
                 logFC = numeric(),
                 FDR = numeric(),
                 Biotype = character(),
                 Significance = character())
    }
  })
  
  
  
  source(file.path("server", "mainTable.R"), local=TRUE)$value
  source(file.path("server", "volcanoPlot.R"), local=TRUE)$value
  source(file.path("server", "summaryTable.R"), local=TRUE)$value
  source(file.path("server", "heatmapPlot.R"), local=TRUE)$value
  source(file.path("server", "goAnalysis.R"), local=TRUE)$value
  source(file.path("server", "keggPlot.R"), local=TRUE)$value
  source(file.path("server", "vennDiagram.R"), local=TRUE)$value
  source(file.path("server", "lncRNATable.R"), local=TRUE)$value
  source(file.path("server", "downloadTable.R"), local=TRUE)$value
  
}

shinyApp(ui, server)