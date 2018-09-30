# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    player_id = NULL,
    team_log = NULL,
    gamelog_team = NULL,
    gamelog_raw = NULL,
    gamelog_out = NULL,
    career_raw = NULL,
    career_out = NULL,
    player_stat_table = NULL
  )
  
  # React to player search -----------------------------------------------
  observeEvent(input$player_search, {
    
    # Clear revals and update options
    names(revals) %>% map(function(x) {revals[[x]]=NULL})
    updatePrettySwitch(session, input$per_36_enable, value = FALSE)
    
    # Player ID
    player_record = player_master %>% filter(player == input$player_name) 
    id_ = player_record %>% pull(player_id)
    revals$player_id = id_
    
    # Update Season Gamelog - for team player play's on
    revals$gamelog_team = get_team_games(player_record %>% pull(teamid))
    
    # Update Season Gamelog - for chosen player
    glraw = get_player_gamelog(id_, season = "2017-18")
    revals$gamelog_raw = glraw
    
    # Update Career Stats
    revals$career_raw = get_player_career_stats(id_)
    
    # Update team games log
    revals$team_log = get_team_games(
      player_master %>% filter(player_id == id_) %>% pull(teamid)
    )
    
    # Peer group
    revals$starter_bench = ifelse(glraw %>% pull(min) %>% mean() > 28, "Starting", "Bench")
    revals$position = player_master %>%
      filter(player_id == id_) %>%
      mutate(position_map = position_mapper(position)) %>%
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
    
    per_mode_label = ifelse(input$per_36_enable, "PER 36 MINS:", "PER GAME:")
    
    # dtab = revals$player_stat_table %>% as.data.frame()
    # rownames(dtab) = dtab$statistic
    
    # Create custom column names for the per mode
    # sketch = htmltools::withTags(table(
    #   class = 'display',
    #   thead(
    #     tr(
    #       th(rowspan = 4, per_mode_label)
    #     ),
    #     tr(
    #       lapply(c("Career Avg", "2017-18", "Peer Median", "Peer %tile"), th)
    #     )
    #   )
    # ))
    
    
    
    datatable(
      #dtab %>% select(-statistic)
      revals$player_stat_table
      , colnames = c('Career Avg', "2017-18", "Peer Median", "Peer %tile")
      , rownames = FALSE
      #, container = sketch
      , selection = "none"
      , class = 'compact hover row-border'
      , options = list(
        dom = 't',
        pageLength = 20,
        columnDefs = list(
          list(className = 'dt-center', targets = c(2, 3, 4))
        )
      )
    )
    
    
  })
  
  # Core Stats
  output$core_season = renderHighchart({
    
    req(revals$gamelog_out)
    req(revals$team_log)
    
    # Stat name & per mode
    core_stat_name = input$core_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    build_season_chart(
      game_log = revals$gamelog_out,
      team_log = revals$team_log,
      season_stat_master = stats_master,
      stat_name = core_stat_name,
      per_mode = per_mode
    )
    #chart_stat_season(revals$gamelog_out, stat_name = core_stat_name, stat_median = stat_median, per_mode = per_mode)
    
  })

  output$core_career = renderHighchart({
    
    req(revals$career_out)
    
    # Stat name & per mode
    core_stat_name = input$core_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    #chart_stat_career(revals$career_out, stat_name = core_stat_name, stat_median = stat_median, per_mode = per_mode)
    build_career_chart(
      career_log = revals$career_out,
      season_stat_master = stats_master,
      stat_name = core_stat_name,
      per_mode = per_mode
    )
    
  })

  output$core_career1 = renderHighchart({
    req(revals$career_out)

    highcharts_demo() %>% hc_add_theme(hc_theme_smoove())
    
  })
  
  
  # Efficiency
  output$efficiency_season = renderHighchart({
    
    # req(revals$gamelog_out)
    
    # # Stat name & per mode
    # eff_stat_name = input$efficiency_stat_type
    # per_mode = per_mode_translation(input$per_36_enable)
    
    # # Get peer median?
    # stat_median = get_peer_median(stats_master, eff_stat_name)
    
    # # Build chart
    # chart_stat_season(revals$gamelog_out, stat_name = eff_stat_name, stat_median = stat_median, per_mode = per_mode)
    
    
    req(revals$gamelog_out)
    req(revals$team_log)
    
    # Stat name & per mode
    eff_stat_name = input$efficiency_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    build_season_chart(
      game_log = revals$gamelog_out,
      team_log = revals$team_log,
      season_stat_master = stats_master,
      stat_name = eff_stat_name,
      per_mode = per_mode
    )
    
  })
  
  output$efficiency_career = renderHighchart({
    
    # req(revals$career_out)
    
    # # Stat name
    # eff_stat_name = input$efficiency_stat_type
    # per_mode = per_mode_translation(input$per_36_enable)
    
    # # Get peer median?
    # stat_median = get_peer_median(stats_master, eff_stat_name)
    
    # # Build chart
    # chart_stat_career(revals$career_out, stat_name = eff_stat_name, stat_median = stat_median, per_mode = per_mode)

    req(revals$career_out)
    
    # Stat name & per mode
    eff_stat_name = input$efficiency_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    #chart_stat_career(revals$career_out, stat_name = core_stat_name, stat_median = stat_median, per_mode = per_mode)
    build_career_chart(
      career_log = revals$career_out,
      season_stat_master = stats_master,
      stat_name = eff_stat_name,
      per_mode = per_mode
    )
  })
  
  output$efficiency_career1 = renderHighchart({
    
    req(revals$career_out)
    
    highcharts_demo() %>% hc_add_theme(hc_theme_smoove())
    
  })
  
  
})








