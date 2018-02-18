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
    
    player_nme = input$player %>% str_split(" ")
    first_name = player_nme[1]
    last_name = player_nme[2]
    
    # Player ID
    id_ = get_player(first_name, last_name)
    
    # Get Game Log
    gl_ = get_player_gamelog(id_)
    
    # Update points
    revals$pts = gf_ %>% pull(pts) %>% mean()
    
  })
  
  # Value Boxes
  output$vb_points <- renderValueBox({
    valueBox(
      revals$pts, "Approval", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "yellow"
    )
  })
  
  
})








