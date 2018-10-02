div(class = "pad-15",
  
  hidden(

      div(class = "results-only",
    
      div(class = "header-box",
        fluidRow(
          
          column(6,
            h4("CORE STATS.")
          )

        )
      ),
   
      selectInput(
        inputId = "core_stat_type", 
        label = "", 
        selected = "Points",
        choices = core_fields
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
      ),

      div(class = "header-box",
        fluidRow(
          
          column(6,
            h4("EFFICIENCY.")
          )

        )
      ),
     
      selectInput(
        inputId = "efficiency_stat_type", 
        label = "", 
        selected = "Field Goal %",
        choices = efficiency_fields
      ),
      
      fluidRow(

        box(width = 12,

          div(class = "player-name-pane-title", textOutput("eff_player_name")),

          highchartOutput("efficiency_season", height = 300),
          fluidRow(
              column(width = 6,
                 highchartOutput("efficiency_career", height = 300)

              ),
              column(width = 6,
                highchartOutput("efficiency_distribution", height = 300)
              )
            
            )
          )
      )
    )
  )
)