
div(class = "sidebar pad-15",       
  # Logo
  # shiny::img(
  #   src = "nba_pocketbook_logo.png", 
  #   local = T
  # ),
  
  # Header
  div(class = "header-box",
    h3("PLAYER.")
  ),
  
  fluidRow(class= "center-children",
    column(8,
      shinyTypeahead::typeaheadInput(
        "player_name", label = "",
        items = 15,
        value = "LeBron James",
        choices = player_master$player
      ) 
      
    ),
    
    column(4,
      
      actionBttn(
        "player_search", 
        label = "Go.", 
        icon = NULL, 
        style = "material-flat",
        color = "primary", 
        size = "sm", 
        block = TRUE, 
        no_outline = TRUE)
    )
    
  ), br(),

  # Overview
  div(class = "header-box",
    h3("OPTIONS.")
  ),
  
  fluidRow(
    column(4,
      prettySwitch(
       inputId = "per_36_enable",
       label = "Per 36", 
       status = "success",
       fill = TRUE
      )
    )

  ), br(),

  
  # Overview
  div(class = "header-box",
    h3("OVERVIEW.")
  ),
    
  DTOutput("player_stat_table")
)