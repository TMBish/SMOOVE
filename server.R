# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    gamelog = NULL,
    charts = NULL,
    player_stat_table = NULL,
    pts = 0,
    rebs = 0,
    assists = 0,
    to = 0
  )
  
  # React to player search -----------------------------------------------
  observeEvent(input$player_search, {
    
    # Player ID
    id_ = player_master %>% filter(player == input$player_name) %>% pull(player_id)
    
    print(id_)
    
    # Get Overview Player Table
    revals$player_stat_table = build_player_table(id_, stats_master, player_master)
    
    # Update points
    #revals$pts = gl_ %>% pull(pts) %>% mean()
    # Update gamelog
    revals$gamelog = get_player_gamelog(id_, season = "2017-18")
    
  })
  
  # Chart build observer
  observe({
    
    if (!is.null(revals$gamelog)) {
      
      revals$charts = build_chart_set(revals$gamelog)

      
    }
    
  })
  
  # Player Stat Overview Table
  output$player_stat_table = renderDT({
    
    datatable(
      revals$player_stat_table
      , colnames = c('Statistic', 'Per Game', "Per36", "Position Per36 Median")
      , rownames = FALSE
      , selection = "none"
      #, style = 'bootstrap'
      , class = 'compact hover row-border'
      , options = list(
        dom = 't',
        pageLength = 20,
        columnDefs = list(
          list(className = 'dt-center', targets = c(1, 2,3))
      )
    ))
    
    
  })
  
  # Core Stats
  output$core_1 = renderHighchart({
    
    chart_type = input$core_stat_type
    
    revals$charts[[chart_type]]
    
  })
  # output$rebounds = renderHighchart({
  #   revals$charts$Rebounds
  # })
  # output$assists = renderHighchart({
  #   revals$charts$Assists
  # })
  # 
  # # Efficiency Stats
  # output$fg_pct = renderHighchart({
  #   revals$charts$`Field Goal %`
  # })
  # output$three_fg_pct = renderHighchart({
  #   revals$charts$`Three Point %`
  # })
  # output$turnovers = renderHighchart({
  #   revals$charts$`Turn Overs`
  # })
  

  
  
  
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








