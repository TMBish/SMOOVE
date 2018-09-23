
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
    column(8,
      shinyTypeahead::typeaheadInput(
        "player_name", label = "",
        items = 15,
        value = "LeBron James",
        choices = player_master$player
      ) 
      
    ),
    
    # column(4,
    #   pickerInput(
    #     inputId = "season", 
    #     label = "", 
    #     choices = c("2017-18", "2016-17", "2015-16"),
    #     options = list(title = "select a season."))
    # ),
    
    column(4,
      
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
  ),
  
  br(),
  
  DTOutput("player_stat_table")
)