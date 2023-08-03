#------------------------------------------------- Venn Diagram ------------------------------------------------------

# creates list of up- or down-regulated genes from all the comparisons of the selected study based on the selected expression pattern 

gene_sets <- reactive ({
  lapply(comparisons(), function(c) {
    
    if (input$expression3 == "up-regulated genes") {
      c <- studyInput() %>%
        filter(Comparison == c & logFC >= input$FC & FDR <= input$FDR) %>%
        pull(Ensembl_ID)
    } else {
      c <- studyInput() %>%
        filter(Comparison == c & logFC <= - input$FC & FDR <= input$FDR) %>%
        pull(Ensembl_ID)
    }
    
  })%>% setNames(comparisons())
  
})

Intersect <- function (x) {
  # Multiple set version of intersect
  # x is a list
  if (length(x) == 1) {
    unlist(x)
  } else if (length(x) == 2) {
    intersect(x[[1]], x[[2]])
  } else if (length(x) > 2){
    intersect(x[[1]], Intersect(x[-1]))
  }
}

overlaps <- reactive({
  Intersect(gene_sets())
})

output$VENN <- renderPlot({
  
  if (input$study == "GSE101409"){
    
    shinyjs::hide("p_onecomparison")
    # plot1 <- plot(eulerr::venn(gene_sets()[1:3]), fill = myCol2, labels = NULL, quantities = TRUE, legend = list(labels=comparisons()[1:3]), main = " ")
    # plot2 <- plot(eulerr::venn(gene_sets()[4:5]), fill = myCol1, labels = NULL, quantities = TRUE, legend = list(labels=comparisons()[4:5]), main = " ")
    # grid.arrange(plot1, plot2)
    plot(eulerr::venn(gene_sets()[1:2]),  fills = list(myCol1),
         labels = NULL, quantities = TRUE, legend = list(labels=comparisons()[1:2]), main = " ")
   
    
  } else if (input$study == "GSE154345" ) {
    
    shinyjs::hide("p_onecomparison")
    
    plot(eulerr::venn(gene_sets()[1:2]),  fills = list(myCol1),
         labels = NULL, quantities = TRUE, legend = list(labels=comparisons()[1:2]), main = " ")
    
  } else if (input$study == "GSE154346") {
    
    shinyjs::hide("p_onecomparison")
    plot(eulerr::venn(gene_sets()[1:2]),  fills = list(myCol1),
         labels = NULL, quantities = TRUE, legend = list(labels=comparisons()[1:2]), main = " ")

    
  } else {
    shinyjs::hide("p_onecomparison")
    
    plot(eulerr::venn(gene_sets()[1:2]),  fills = list(myCol1),
         labels = NULL, quantities = TRUE, legend = list(labels=comparisons()[1:2]), main = " ")
    
  }
})

# display correct table with shared DEGs based on selected study

observe({

  if (input$study == "GSExxxx"){
    shinyjs::show("title1")
    shinyjs::show("txt1")
    shinyjs::show("VENN_info1")

    shinyjs::show("title2")
    shinyjs::show("txt2")
    shinyjs::show("VENN_info2")

    shinyjs::hide("title")
    shinyjs::hide("VENN_info")



  } else if (input$study == "GSE154345" | input$study == "GSE154346" |input$study == "GSE181889" | input$study == "GSE191054" | input$study == "GSE101409") {
    shinyjs::show("title")
    shinyjs::show("VENN_info")
    
    shinyjs::hide("title1")
    shinyjs::hide("txt1")
    shinyjs::hide("VENN_info1")
    shinyjs::hide("title2")
    shinyjs::hide("txt2")
    shinyjs::hide("VENN_info2")


  } else if (input$study == "GSE163361") {

    shinyjs::show("title1")
    shinyjs::show("txt1")
    shinyjs::show("VENN_info1")

    shinyjs::show("title2")
    shinyjs::show("txt2")
    shinyjs::show("VENN_info2")

    shinyjs::hide("title")
    shinyjs::hide("VENN_info")
  }
})

output$VENN_info <- renderPrint({

  cat(Intersect(gene_sets()[1:2]))

})

# output$VENN_info3 <- renderPrint({
#   
#   cat(Intersect(gene_sets()[1:2]))
#   
# })

output$VENN_info1 <- renderPrint({

  cat(Intersect(gene_sets()[1:2]))

})

output$VENN_info2 <- renderPrint({

  cat(Intersect(gene_sets()[4:5]))

})


