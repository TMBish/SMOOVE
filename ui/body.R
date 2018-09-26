div(class = "pad-15",
  
  div(class = "header-box",
  fluidRow(
    
    column(6,

      h4("CORE STATS.")

    )

  )
  ),
 
  pickerInput(
    inputId = "core_stat_type", 
    label = "", 
    selected = "Points",
    choices = core_fields,
    options = list(title = "SELECT A STAT.")
  ),
  
  fluidRow(
    box(width = 12,
      highchartOutput("core_season", height = 300),
    # ),
    fluidRow(
        column(width = 6,
           highchartOutput("core_career", height = 250)

        ),
        column(width = 6,
          highchartOutput("core_career1", height = 250)
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
   
    pickerInput(
      inputId = "efficiency_stat_type", 
      label = "", 
      selected = "Field Goal %",
      choices = efficiency_fields,
      options = list(title = "SELECT A STAT.")
    ),
    
    fluidRow(
      box(width = 12,
        highchartOutput("efficiency_season", height = 300),
      # ),
      fluidRow(
          column(width = 6,
             highchartOutput("efficiency_career", height = 250)

          ),
          column(width = 6,
            highchartOutput("efficiency_career1", height = 250)
          )
        
        )
      )
    )


  
)