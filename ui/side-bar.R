
div(class = "sidebar key-info-box pad-15",       
  
  # ++++++++++++++++++++++++
  # PLAYER SECTION
  # ++++++++++++++++++++++++
  div(class = "header-box",
    h4("PLAYER.")
  ), br(),
  
  # Season
  fluidRow(
    
    column(6,
      pickerInput(
       inputId = "season",
       label = "SEASON:", 
       choices = c("2018-19", "2017-18"),
       options = list(title = "select season.")
      )
    )
  ),
  
  hidden(
    fluidRow(id = "player-search-row", class= "center-children",
    column(8, class = "centered",
      # shinyTypeahead::typeaheadInput(
      #   "player_name", label = "",
      #   items = 15,
      #   value = "LeBron James",
      #   choices = c(1,2,3,4, "LeBron James") 
      #   #player_master$player
      # )
      
      uiOutput("player_search", class = "width-100")
    ),
    
    column(4, class = "centered",
      
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
    
  )
  ), br(),

  # ++++++++++++++++++++++++
  # OPTIONS
  # ++++++++++++++++++++++++

  div(class = "header-box",
    h4("OPTIONS.")
  ), br(),
  
  fluidRow(
    column(4,
      #class = "drop-27",
      prettySwitch(
       inputId = "per_36_enable",
       label = "Per 36", 
       status = "success",
       fill = TRUE
      )
    )
  ), br(),

  
  # ++++++++++++++++++++++++
  # OVERVIEW
  # ++++++++++++++++++++++++

  div(class = "header-box",
    h4("OVERVIEW.")
  ), br(),
  
  # Overview body
  hidden(
    div(class="results-only",

      div(class="numberCircle", "i"),
      br(),
      #div(class = "centered", textOutput("peergrp")),
      htmlOutput("player_info"),
      
      br(),
      
      div(class="numberCircle", "ii"),
      DTOutput("player_stat_table")
    )
  )


)