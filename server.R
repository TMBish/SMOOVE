# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    player_id = NULL,
    player_name = NULL,
    season = NULL,
    player_data = NULL,
    #player_stats_raw = NULL,
    #player_stats_out = NULL,
    team_log = NULL,
    gamelog_raw = NULL,
    gamelog_out = NULL,
    career_raw = NULL,
    career_out = NULL,
    player_stat_table = NULL,
    starter_bench = NULL,
    position = NULL,
    peer_stats_raw = NULL,
    peer_stats_out = NULL
  )
  
  # React to player search -----------------------------------------------
  observeEvent(input$player_search, {
    
    # Hide any containers relevent
    hide(selector = ".results-only", anim =TRUE)

    # Clear revals and update options
    names(revals) %>% map(function(x) {revals[[x]]=NULL})
    updatePrettySwitch(session, "per_36_enable", value = FALSE)
    
    # Player ID
    player_record = player_master %>% filter(player == input$player_name) 
    id_ = player_record %>% pull(player_id)
    revals$player_id = id_
    revals$player_data = player_record

    # Update career stats
    career_raw = get_player_career_stats(id_)
    revals$career_raw = career_raw

    # Update season gamelog - we'll take the most recent available season in the career log
    glraw = get_player_gamelog(id_, season = career_raw %>% tail(1) %>% pull(season_id))
    revals$gamelog_raw = glraw

    # Update team games log
    revals$team_log = build_team_log(career_raw)
    
    # Peer group
    starter_bench = ifelse(glraw %>% pull(min) %>% mean() > 26, "Starting", "Bench")
    
    position = 
      player_master %>%
        filter(player_id == id_) %>%
        mutate(position_map = position_mapper(position)) %>%
        pull(position_map)
        
    peer_stats = get_peer_stats(stats_master, player_master, starter_bench, position)
    
    # Add to revals
    revals$starter_bench = starter_bench
    revals$position = position
    revals$peer_stats_raw = peer_stats
    revals$player_name = input$player_name %>% str_to_upper() %>% str_c(".")

    # Default season to most recent
    #def_season = career_raw %>% tail(1) %>% pull(season_id)
    #revals$season = def_season

    # Update Season Select Input
    # updateSelectInput(
    #   session, 
    #   inputId = "season_select", 
    #   label = "",
    #   choices = career_raw %>% pull(season_id) %>% unique(),
    #   selected = def_season
    # )
    
  })

  # Reacts to season update -----------------------------------------------
  # observe({

  #   req(revals$player_id)
  #   req(revals$career_raw)
  #   req(revals$season)

  #   # Update Season Gamelog - for chosen player
  #   glraw = get_player_gamelog(revals$player_id, season = revals$season)
  #   revals$gamelog_raw = glraw

  #   # Update team games log
  #   revals$team_log = build_team_log(revals$career_raw, season = revals$season)

  #   # Peer group
  #   starter_bench = ifelse(glraw %>% pull(min) %>% mean() > 26, "Starting", "Bench")
  #   position = 
  #     player_master %>%
  #       filter(player_id == revals$player_id) %>%
  #       mutate(position_map = position_mapper(position)) %>%
  #       pull(position_map)

  #   # Player Stats
  #   player_stats = get_all_player_stats(season = revals$season)

  #   # Peer Stats
  #   peer_stats = get_peer_stats(player_stats, player_master, starter_bench, position)
    
  #   # Add to revals
  #   revals$player_stats_raw = player_stats
  #   revals$starter_bench = starter_bench
  #   revals$position = position
  #   revals$peer_stats_raw = peer_stats

  #   # Show results
  #   show(selector = ".results-only", anim =TRUE)

  # })

  # Build table observer
  observe({
    
    req(revals$career_raw)
    req(revals$player_id)
    req(revals$peer_stats_out)
    
    player_overview_table = build_player_table(
      revals$player_id, 
      stats_master, 
      player_master, 
      revals$career_raw,
      peer_stats = revals$peer_stats_out,
      per36 = input$per_36_enable
    )
    
    revals$player_stat_table = player_overview_table
    
  })

  # Per Mode Observer
  observe({
    
    # Require these objects
    req(revals$gamelog_raw)
    req(revals$career_raw)
    req(revals$peer_stats_raw)

    # Convert stats to per_mode 
    # Also dedupe the career data for midseason trades
    if (input$per_36_enable) {
      revals$gamelog_out = revals$gamelog_raw %>% gamelog_to_perM()
      revals$career_out = revals$career_raw %>% dedupe_player_career_stats() %>% career_to_perM()
      revals$peer_stats_out = revals$peer_stats_raw %>% allplayerstats_to_perM()
    } else {
      revals$gamelog_out = revals$gamelog_raw
      revals$career_out = revals$career_raw %>% dedupe_player_career_stats()
      revals$peer_stats_out = revals$peer_stats_raw
    }

    # Show results
    show(selector = ".results-only", anim =TRUE)
    
  })
  
  # Peer group
  # output$peergrp = renderText({
  #   req(revals$position)
  #   req(revals$starter_bench)
    
  #   pos_ = case_when(
  #     revals$position == "F" ~ "Forwards",
  #     revals$position == "G" ~ "Guards",
  #     TRUE ~ "Centers"
  #   )
    
  #   glue("Peer Group: {revals$starter_bench} {pos_}") %>% return()
  
  # })
  
  # Player Stat Overview Table
  output$player_stat_table = renderDT({
    
    req(revals$player_stat_table)
    
    # Label for the per mode
    per_mode_label = ifelse(input$per_36_enable, "PER 36 MINUTES", "PER GAME")
    
    # Insert statistic into rownames
    dtab = revals$player_stat_table %>% as.data.frame()
    rownames(dtab) = dtab$statistic
    dtab = dtab %>% select(-statistic)
    
    # Create custom column names for the per mode
    column_container = htmltools::withTags(table(
      class = 'display dt-center',
      thead(
        tr(
          th(rowspan = 2, ""),
          th(colspan = 4, per_mode_label)
        ),
        tr(
          lapply(c("Career Avg", "2017-18", "Peer Median", "Peer %tile"), th)
        )
      )
    ))
    
    datatable(
      dtab
      , container = column_container
      , selection = "none"
      , class = 'compact hover row-border'
      , options = list(
        dom = 't',
        pageLength = 20,
        columnDefs = list(
          list(className = 'dt-center', targets = c(1, 2, 3, 4)),
          list(className = "dt-right", targets = 0)
        )
      )
    )
    
    
  })
  
  # Core Stats
  output$core_season = renderHighchart({
    
    req(revals$gamelog_out)
    req(revals$team_log)
    req(revals$peer_stats_out)
    
    # Stat name & per mode
    core_stat_name = input$core_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    build_season_chart(
      game_log = revals$gamelog_out,
      team_log = revals$team_log,
      peer_stats = revals$peer_stats_out,
      stat_name = core_stat_name,
      per_mode = per_mode
    )
    
  })

  output$core_career = renderHighchart({
    
    req(revals$career_out)
    req(revals$peer_stats_out)
    
    # Stat name & per mode
    core_stat_name = input$core_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    build_career_chart(
      career_log = revals$career_out,
      peer_stats = revals$peer_stats_out,
      stat_name = core_stat_name,
      per_mode = per_mode
    )
    
  })

  output$core_distribution = renderHighchart({
    
    req(revals$peer_stats_out)
    req(revals$player_id)
    
    # Stat name & per mode
    per_mode = per_mode_translation(input$per_36_enable)
    core_stat_name = input$core_stat_type
    
    build_distribution_chart(
      player_id = revals$player_id,
      peer_stats = revals$peer_stats_out,
      stat_name = core_stat_name,
      per_mode = per_mode
    )
    
  })
  
  
  # Efficiency
  output$efficiency_season = renderHighchart({
    
    req(revals$gamelog_out)
    req(revals$team_log)
    req(revals$peer_stats_out)
    
    # Stat name & per mode
    eff_stat_name = input$efficiency_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    build_season_chart(
      game_log = revals$gamelog_out,
      team_log = revals$team_log,
      peer_stats = revals$peer_stats_out,
      stat_name = eff_stat_name,
      per_mode = per_mode
    )
    
  })
  
  output$efficiency_career = renderHighchart({
    
    req(revals$career_out)
    req(revals$peer_stats_out)
    
    # Stat name & per mode
    eff_stat_name = input$efficiency_stat_type
    per_mode = per_mode_translation(input$per_36_enable)
    
    # Build chart
    #chart_stat_career(revals$career_out, stat_name = core_stat_name, stat_median = stat_median, per_mode = per_mode)
    build_career_chart(
      career_log = revals$career_out,
      peer_stats = revals$peer_stats_out,
      stat_name = eff_stat_name,
      per_mode = per_mode
    )
  })
  
  output$efficiency_distribution = renderHighchart({
    
    req(revals$peer_stats_out)
    req(revals$player_id)
    
    # Stat name & per mode
    eff_stat_name = input$efficiency_stat_type
    per_mode = per_mode_translation(input$per_36_enable)

    
    build_distribution_chart(
      player_id = revals$player_id,
      peer_stats = revals$peer_stats_out,
      stat_name = eff_stat_name,
      per_mode = per_mode
    )
  })


  output$core_player_name = renderText({
    req(revals$player_name)
    revals$player_name
  })
  output$eff_player_name = renderText({
    req(revals$player_name)
    revals$player_name
  })

  output$player_info = renderUI({
    
    req(revals$player_data)
    req(revals$position)
    req(revals$starter_bench)
    
    pos_ = case_when(
      revals$position == "F" ~ "Forwards",
      revals$position == "G" ~ "Guards",
      TRUE ~ "Centers"
    )
    
    txt =
      revals$player_data %>%
      mutate(
        info = glue("
          <b> Height: </b> {height} <br>
          <b> Weight: </b> {weight} lbs <br>
          <b> Age: </b> {age} <br>
          <b> College: </b> {school} <br>
        ")
      ) %>%
      pull(info)

    glue("<b> Peer Group: </b> {revals$starter_bench} {pos_} <br> {txt}") %>%
    HTML()

  })


  
})








