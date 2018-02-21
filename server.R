# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    gamelog = NULL,
    pts = 0,
    rebs = 0,
    assists = 0,
    to = 0
  )
  
  # React to player search -----------------------------------------------
  observeEvent(input$player_search, {
    
    player_nme = input$player %>% str_split(" ", simplify = TRUE)
    first_name = player_nme[1]
    last_name = player_nme[2]
    
    # Player ID
    id_ = get_player(first_name, last_name)
    
    # Get Game Log
    gl_ = get_player_gamelog(id_)
    
    # Update points
    revals$pts = gl_ %>% pull(pts) %>% mean()
    
  })
  
  # Value Boxes
  output$vb_points <- renderValueBox({
    valueBox(
      revals$pts, "Points", icon = icon("adjust", lib = "font-awesome"),
      color = "blue", width = 12
    )
  })
  
  output$vb_rebounds <- renderValueBox({
    valueBox(
      revals$pts, "Rebounds", icon = icon("adjust", lib = "font-awesome"),
      color = "blue", width = 12
    )
  })
  
  output$vb_assists <- renderValueBox({
    valueBox(
      revals$pts, "Assists", icon = icon("adjust", lib = "font-awesome"),
      color = "blue", width = 12
    )
  })
  
  output$vb_to <- renderValueBox({
    valueBox(
      revals$pts, "Turnovers", icon = icon("adjust", lib = "font-awesome"),
      color = "blue", width = 12
    )
  })
  
  
})








