
div(class = "sidebar",       
  # Logo
  # shiny::img(
  #   src = "nba_pocketbook_logo.png", 
  #   local = T
  # ),
  
  # Header
  div(class = "header-box",
    h1("PLAYER.")
  ),
  
  fluidRow(class= "center-children",
    column(9,
      shinyTypeahead::typeaheadInput(
        "player_name", label = "",
        items = 15,
        value = "Lebron James",
        choices = player_master$player
      ) 
      
    ),
    
    column(3,
      
      actionBttn(
        "player_search", 
        label = "Go.", 
        icon = NULL, 
        style = "material-flat",
        color = "primary", 
        size = "md", 
        block = TRUE, 
        no_outline = TRUE)
    )
    
  ),

  
  # Overview
  div(class = "header-box",
    h1("OVERVIEW.")
  )
)