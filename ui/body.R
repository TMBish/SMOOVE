div(class = "pad-15",
  
  hidden(
    
      div(class = "results-only",
    
      div(class = "header-box",
        fluidRow(
          
          column(6,
            h4("TRADITIONAL STATS.")
          )
          
        )
      ),
      
      pickerInput(
        inputId = "core_stat_type",
        label = "", 
        choices = list(
          core = core_fields,
          shooting = efficiency_fields
        ),
        selected = "Points"
      ),
    
      
      fluidRow(
        box(width = 12,
          
          div(class = "player-name-pane-title", textOutput("core_player_name")),
          
          highchartOutput("core_season", height = 300),
          
          fluidRow(
              column(width = 6,
                 highchartOutput("core_career", height = 300)
                 
              ),
              column(width = 6,
                highchartOutput("core_distribution", height = 300)
              )
            
            )
          )
      )
      
    )
  )
)