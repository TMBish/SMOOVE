div(
  
  div(class = "header-box",
  fluidRow(
    
    column(6,

      h1("CORE STATS.")

    ),

    column(6,

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
      highchartOutput("core_career")
    ),
    
    box(width = 6,
      highchartOutput("core_season")
    )
    
  )
  
)