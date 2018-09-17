div(
  
  h2("Core Stats"),
  
  fluidRow(
    box(width = 4,
      highchartOutput("points")
    ),
    
    box(width = 4,
      highchartOutput("rebounds")
    ),
    
    box(width = 4,
      highchartOutput("assists")
    )
  ),
  
  h2("Efficiency"),
  
  fluidRow(
    box(width = 4,
       highchartOutput("fg_pct")
    ),
    
    box(width = 4,
       highchartOutput("three_fg_pct")
    ),
    
    box(width = 4,
       highchartOutput("turnovers")
    )
  ),
 
  h2("Defense"),
  
  fluidRow(
    box(width = 4,
      highcharts_demo()
    ),
    
    box(width = 4,
      highcharts_demo()
    ),
    
    box(width = 4,
      highcharts_demo()
    )
  )
)