# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    gamelog_raw = NULL,
    gamelog_out = NULL,
    career_raw = NULL,
    career_out = NULL,
    player_stat_table = NULL,
    season_charts = NULL,
    career_charts = NULL
  )
  
  # React to player search -----------------------------------------------
  observeEvent(input$player_search, {
    
    # Player ID
    id_ = player_master %>% filter(player == input$player_name) %>% pull(player_id)
    
    # Get Overview Player Table
    revals$player_stat_table = build_player_table(id_, stats_master, player_master)
    
    # Update Season Gamelog
    revals$gamelog_raw = get_player_gamelog(id_, season = "2017-18")
    
    # Update Career Stats
    revals$career_raw = get_player_career_stats(id_)
    
  })

  # Per Mode Observer
  observe({
    
    # Require these objects
    req(revals$gamelog_raw)
    req(revals$career_raw)

    # Convert
    if (input$per_36_enable) {
      revals$gamelog_out = gamelog_to_perM(revals$gamelog_raw)
      revals$career_out = career_to_perM(revals$career_raw)
    } else {
      revals$gamelog_out = revals$gamelog_raw
      revals$career_out = revals$career_raw
    }

  })

  
  # Chart build observer
  observe({
    
    if (!is.null(revals$gamelog_out)) {
      revals$season_charts = build_season_charts(revals$gamelog_out)
    }
    
    if (!is.null(revals$career_out)) {
      revals$career_charts = build_career_charts(revals$career_out)
    }
    
  })
  
  # Player Stat Overview Table
  output$player_stat_table = renderDT({
    
    req(revals$player_stat_table)
    
    dtab = revals$player_stat_table %>% as.data.frame()
    rownames(dtab) = dtab$statistic
    
    datatable(
      dtab %>% select(-statistic)
      , colnames = c( 'Per Game', "Per 36 Mins", "Pos. Per36 Median")
      #, rownames = FALSE
      , selection = "none"
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

    output$core_career1 = renderHighchart({
    
    chart_type = input$core_stat_type
    revals$career_charts[[chart_type]]
    
  })
  
  
  # Efficiency
  output$efficiency_season = renderHighchart({
    
    chart_type = input$efficiency_stat_type
    revals$season_charts[[chart_type]]
    
  })
  
  output$efficiency_career = renderHighchart({
    
    chart_type = input$efficiency_stat_type
    revals$career_charts[[chart_type]]
    
  })
  
})








