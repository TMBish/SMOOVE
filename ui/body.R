div(
  
  fluidRow(
    
    column(12,  div(class = "header-box", 
      
      h1("CORE STATS."),
      pickerInput(
        inputId = "core_stat_type", 
        label = "", 
        selected = "Points",
        choices = c("Points", "Rebounds", "Assists"),
        options = list(title = "SELECT A STAT.")
      )
    )
  )
  ),
 
  
  fluidRow(
    box(width = 6,
      highchartOutput("core_1")
    ),
    
    box(width = 6,
      highchartOutput("rebounds")
    )
    
  )
  
)