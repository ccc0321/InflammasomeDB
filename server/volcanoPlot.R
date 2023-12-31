# ------------------------------------------ Volcano plot ------------------------------------

# for ggplot name -- display name only if Biotype and selected gene type match. 
selected_gene <- reactive({
  if(nrow(selected_row()) == 0) {
    title <- ""
  } else if (!is.null(selected_row())) {
    title <- selected_row()[,"Gene_symbol"]
  }
  
  title
  
})


size <- reactive({
  size <- rep(1, nrow(studyInput_mutated()))
  
  if (!is.null(selected_row())) {
    size[studyInput_mutated()$Gene_symbol == selected_row()$Gene_symbol] <- 5
  }
  
  size
  
})

output$volcano <- renderPlot({
  
  ggplot(studyInput_mutated(), aes(x=logFC, y=-log10(FDR), col=Significance, size=size()))+
    geom_point()+
    theme_bw() +
    scale_size_continuous(guide = "none") +
    xlab(expression("log"[2]*"FC")) +
    ylab(expression("-log"[10]*"FDR")) +
    scale_color_manual(values = c("Unchanged" = "gray",
                                  "Down-reg protein-coding gene" = "firebrick1",
                                  "Up-reg protein-coding gene" = "dodgerblue3",
                                  "Down-reg lncRNA" = "seagreen4",
                                  "Up-reg lncRNA" = "purple4")) +
    guides(colour = guide_legend(override.aes = list(size=1.5)))+
    theme(axis.title = element_text(size=18),
          axis.text=element_text(size=11),
          legend.text=element_text(size=14),
          legend.title=element_blank(),
          plot.title=element_text(size=20),
          plot.subtitle = element_text(size=15))+
    labs(title=input$comparison, subtitle=selected_gene())
})