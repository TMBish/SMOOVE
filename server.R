# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    player_id = NULL,
    player_name = NULL,
    season = NULL,
    player_data = NULL,
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
    show("loading-container", anim =TRUE)

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
    revals$team_log = build_team_log(career_raw, season)
    
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
    
  })
  

  # Charts ----------------------------------------------------------
  source("./server/server-charts.R", local=TRUE)
  
  # Tables and Info ----------------------------------------------------------
  source("./server/server-tables-and-info.R", local = TRUE)
  
  # Loader----------------------------------------------------------
  observe({
    
    req(revals$efficiency_charts)
    req(revals$core_charts)
    req(revals$player_stat_table)
    
    show(selector = ".results-only", anim =TRUE)
    hide("loading-container", anim =TRUE)
    
  })
  

  
})








