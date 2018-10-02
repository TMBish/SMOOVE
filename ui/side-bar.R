
div(class = "sidebar key-info-box pad-15",       
  
  # ++++++++++++++++++++++++
  # PLAYER SECTION
  # ++++++++++++++++++++++++
  div(class = "header-box",
    h4("PLAYER.")
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
    
    column(4,  class = "drop-27",
      
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

  # ++++++++++++++++++++++++
  # OPTIONS
  # ++++++++++++++++++++++++

  div(class = "header-box",
    h4("OPTIONS.")
  ), br(),
  
  fluidRow(
    column(3, 
      #class = "drop-27",
      prettySwitch(
       inputId = "per_36_enable",
       label = "Per 36", 
       status = "success",
       fill = TRUE
      )
    )
    # column(4, 
    #   selectInput(
    #    inputId = "season_select",
    #    label = "", 
    #    choices = "2017-18"
    #    #status = "success",
    #    #fill = TRUE
    #   )
    # )

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
      div(class = "centered", textOutput("peergrp")),

      br(),
      
      div(class="numberCircle", "ii"),
      DTOutput("player_stat_table")
    )
  )


)