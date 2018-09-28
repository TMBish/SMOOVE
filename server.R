# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    player_id = NULL,
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
    revals$player_id = id_
    
    # Update Season Gamelog
    glraw = get_player_gamelog(id_, season = "2017-18")
    revals$gamelog_raw = glraw
    
    # Update Career Stats
    revals$career_raw = get_player_career_stats(id_)
    
    # Peer group
    revals$starter_bench = ifelse(glraw %>% pull(min) %>% mean() > 28, "Starting", "Bench")
    revals$position = 
      player_master %>%
      filter(player_id == id_) %>%
      mutate(position_map = case_when(
        position == "C-F" ~ "C",
        position == "G-F" ~ "G",
        position == "F-G" ~ "F",
        position == "F-C" ~ "F",
        TRUE ~ position
      )) %>%
      pull(position_map)
      
    
  })

  # Build table observer
  observe({
    
    req(revals$career_raw)
    req(revals$player_id)
    req(revals$position)
    req(revals$starter_bench)
    
    player_overview_table = build_player_table(
      revals$player_id, 
      stats_master, 
      player_master, 
      revals$career_raw,
      starter_bench = revals$starter_bench,
      position = revals$position,
      per36 = input$per_36_enable
    )
    
    
    revals$player_stat_table = player_overview_table
    
    
    
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
  
  # Peer group
  output$peergrp = renderText({
    req(revals$position)
    req(revals$bench_starter)
    
    pos_ = case_when(
      revals$position == "F" ~ "Forwards",
      revals$position == "G" ~ "Guards",
      TRUE ~ "Centers"
    )
    
    glue("Peer Group: {tolower(revals$bench_starter)} {pos_}}") %>%
    return()
  })
  
  # Player Stat Overview Table
  output$player_stat_table = renderDT({
    
    req(revals$player_stat_table)
    
    dtab = revals$player_stat_table %>% as.data.frame()
    rownames(dtab) = dtab$statistic
    
    datatable(
      dtab %>% select(-statistic)
      , colnames = c( 'Career Avg', "2017-18", "Peer Median", "Peer %tile")
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
    
    req(revals$gamelog_out)
    
    # Stat name
    core_stat_name = input$core_stat_type
    
    # Get peer median?
    stat_median = get_peer_median(stats_master, core_stat_name)
    
    # Build chart
    chart_stat_season(revals$gamelog_out, stat_name = core_stat_name, stat_median = stat_median)
    
  })

  output$core_career = renderHighchart({
    
    req(revals$career_out)
    
    # Stat name
    core_stat_name = input$core_stat_type
    
    # Get peer median?
    stat_median = get_peer_median(stats_master, core_stat_name)
    
    # Build chart
    chart_stat_career(revals$career_out, stat_name = core_stat_name, stat_median = stat_median)
    
  })

  output$core_career1 = renderHighchart({
    
    req(revals$career_out)
    
    # Stat name
    core_stat_name = input$core_stat_type
    
    # Get peer median?
    stat_median = get_peer_median(stats_master, core_stat_name)
    
    # Build chart
    highcharts_demo() %>% hc_add_theme(hc_theme_smoove())
    #chart_stat_career(revals$career_out, stat_name = core_stat_name, stat_median = stat_median)
    
  })
  
  
  # Efficiency
  output$efficiency_season = renderHighchart({
    
    req(revals$gamelog_out)
    
    # Stat name
    eff_stat_name = input$efficiency_stat_type
    
    # Get peer median?
    stat_median = get_peer_median(stats_master, eff_stat_name)
    
    # Build chart
    chart_stat_season(revals$gamelog_out, stat_name = eff_stat_name, stat_median = stat_median)
    
  })
  
  output$efficiency_career = renderHighchart({
    
    req(revals$career_out)
    
    # Stat name
    eff_stat_name = input$efficiency_stat_type
    
    # Get peer median?
    stat_median = get_peer_median(stats_master, eff_stat_name)
    
    # Build chart
    chart_stat_career(revals$career_out, stat_name = eff_stat_name, stat_median = stat_median)
    
  })
  
    output$efficiency_career1 = renderHighchart({
    
    req(revals$career_out)
    
    # Stat name
    eff_stat_name = input$efficiency_stat_type
    
    # Get peer median?
    stat_median = get_peer_median(stats_master, eff_stat_name)
    
    # Build chart
    chart_stat_career(revals$career_out, stat_name = eff_stat_name, stat_median = stat_median)
    
  })
  
  
})








