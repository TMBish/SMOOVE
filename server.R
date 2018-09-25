# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    gamelog = NULL,
    season_charts = NULL,
    career_charts = NULL,
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
    
    # Update Season Gamelog
    revals$gamelog = get_player_gamelog(id_, season = "2017-18")
    
    # Update Career Stats
    revals$career = get_player_career_stats(id_)
    
  })
  
  # Chart build observer
  observe({
    
    if (!is.null(revals$gamelog)) {
      
      revals$season_charts = build_season_charts(revals$gamelog)

      
    }
    
    if (!is.null(revals$career))
    
      revals$career_charts = build_career_charts(revals$career)
  })
  
  # Player Stat Overview Table
  output$player_stat_table = renderDT({
    
    datatable(
      revals$player_stat_table
      , colnames = c('Statistic', 'Per Game', "Per 36 Mins", "Pos. Per36 Median")
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
  output$core_season = renderHighchart({
    
    chart_type = input$core_stat_type
    
    revals$season_charts[[chart_type]]
    
  })
  
  output$core_career = renderHighchart({
    
    chart_type = input$core_stat_type
    
    revals$career_charts[[chart_type]]
    
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








