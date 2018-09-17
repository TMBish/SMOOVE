# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    gamelog = NULL,
    charts = NULL,
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
    gl_ = get_player_gamelog(id_, season = "2017-18")
    
    # Update points
    #revals$pts = gl_ %>% pull(pts) %>% mean()
    # Update gamelog
    revals$gamelog = gl_
    
  })
  
  # Chart build observer
  observe({
    
    if (!is.null(revals$gamelog)) {
      
      revals$charts = build_chart_set(revals$gamelog)

      
    }
    
  })
  
  # Core Stats
  output$points = renderHighchart({
    revals$charts$Points
  })
  output$rebounds = renderHighchart({
    revals$charts$Rebounds
  })
  output$assists = renderHighchart({
    revals$charts$Assists
  })
  
  # Efficiency Stats
  output$fg_pct = renderHighchart({
    revals$charts$`Field Goal %`
  })
  output$three_fg_pct = renderHighchart({
    revals$charts$`Three Point %`
  })
  output$turnovers = renderHighchart({
    revals$charts$`Turn Overs`
  })
  

  
  
  
  # Value Boxes
  # output$vb_points <- renderValueBox({
  #   valueBox(
  #     revals$pts, "Points", icon = icon("adjust", lib = "font-awesome"),
  #     color = "blue", width = 12
  #   )
  # })
  
  # output$vb_rebounds <- renderValueBox({
  #   valueBox(
  #     revals$pts, "Rebounds", icon = icon("adjust", lib = "font-awesome"),
  #     color = "blue", width = 12
  #   )
  # })
  
  # output$vb_assists <- renderValueBox({
  #   valueBox(
  #     revals$pts, "Assists", icon = icon("adjust", lib = "font-awesome"),
  #     color = "blue", width = 12
  #   )
  # })
  
  # output$vb_to <- renderValueBox({
  #   valueBox(
  #     revals$pts, "Turnovers", icon = icon("adjust", lib = "font-awesome"),
  #     color = "blue", width = 12
  #   )
  # })
  
  
})








