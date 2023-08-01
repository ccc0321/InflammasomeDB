#-------------------------------------------------table download------------------------------------------------------
datasetInput <- reactive({
  if(input$dataset == "GSE101409"){
    data <- data.frame(fread("data/GSE101409-macrophage-subcellular-Unstranded-All_Samples.txt"), check.names = F)
  } else if (input$dataset == "GSE154345"){
    data <- data.frame(fread("data/GSE154345-PBMC-M1-M2-Unstranded-All_Samples.txt"), check.names = F)
  } else if (input$dataset == "GSE154346"){
    data <- data.frame(fread("data/GSE154346-THP-1-M1-M2-Unstranded-All_Samples.txt"), check.names = F)
  }
  
  on.exit(rm(data))
  
  return(data)
})


output$table2 <- DT::renderDataTable(
  DT::datatable({
    datasetInput()
    
  }, options=list(scrollX=TRUE)))

output$downloadData <- downloadHandler(
  
  # This function returns a string which tells the client browser what name to use when saving the file.
  filename = function() {
    paste(input$dataset, input$filetype, sep = ".")
  },
  
  # This function should write data to a file given to it by the argument 'file'.
  content = function(file) {
    sep <- switch(input$filetype, "csv" = ",", "tsv" = "\t")
    
    # Write to a file specified by the 'file' argument
    write.table(datasetInput(), file, sep = sep,
                row.names = FALSE, quote=F)
  }
)