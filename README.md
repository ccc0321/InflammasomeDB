# InflammasomeDB

Shiny app for exploring RNA-seq data of inflammasome-regulated genes analysed by Qian et al. 2023.

To generate the data for this app, please see the steps in https://github.com/heartlncrna/Analysis_of_Inflammasome_Study.

## Run the app locally

 1. Start R
 
 2. Load the "Shiny" library package (install if not already available)
 ```
 library(shiny)
 
 install.packages("shiny") # ----- if not already installed
 ```
 
 3. Run App
 
 ```
runGitHub(repo = "InflammasomeDB", username = "ccc0321", ref = "main")

 ```
 
 ## Visit the app online
 
 You can find the app online at:  https://qianna0321.shinyapps.io/inflammasomedb/. 
