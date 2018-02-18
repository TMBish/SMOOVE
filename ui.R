shinyUI(
  
  fluidPage(
    
    # Shiny Dashboard CSS
    tags$head(
      includeCSS(file.path('www', path = "AdminLTE.css")),
      includeCSS(file.path('www', path = "shinydashboard.css"))
    ),
    
    br(),
    
    fluidRow(
      
      column(2,
             
             searchInput(inputId = "player", 
                         label = "Enter a player name:", 
                         placeholder = "Lebron James", 
                         btnSearch = icon("search"), 
                         btnReset = icon("remove"), 
                         width = "100%")
             
             ),
      
      
      column(10,
             
             
             source("./ui/top-row.R", local=TRUE)$value
             
             )
      
      
      
    )
    
    
  )
)











