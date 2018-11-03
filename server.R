# Server logic
shinyServer(function(input, output, session) {
  
  # Reactive Values Store ---------------------------------------------------
  revals = reactiveValues(
    player_master = NULL,
    stats_master = NULL,
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
    peer_stats_out = NULL,
    core_charts = NULL
  )
  
  # React to season input -----------------------------------------------
  observe({
    
    if (input$season != "") {
    
      player_master = build_player_info(input$season)
      stats_master = build_player_stats(input$season)
      
      # Total minutes or minutes per game?
      stats_master =
        stats_master %>%
        mutate(
          min = ifelse(min > 50, round(min / gp, 2), min)
        )
      
      revals$player_master = player_master
      revals$stats_master = stats_master
    
    }
    
    
  })
  
  # React to player search -----------------------------------------------
  observeEvent(input$player_search, {
    
    # Hide any containers relevent
    hide(selector = ".results-only", anim =TRUE)
    show("loading-container", anim =TRUE)

    # Clear revals and update options
    names(revals) %>% map(
      function(x) {
        if (!(x %in% c("player_master", "stats_master"))) {
          revals[[x]]=NULL
        }
      })
    updatePrettySwitch(session, "per_36_enable", value = FALSE)
    
    # Player ID
    player_record = revals$player_master %>% filter(player == input$player_name) 
    id_ = player_record %>% pull(player_id)
    revals$player_id = id_
    revals$player_data = player_record

    # Get career stats and gamelog
    glraw = tryCatch({
      get_player_gamelog(id_, season = input$season)
    }, error = function(e){NULL})
    career_raw = tryCatch({
      get_player_career_stats(id_)
    }, error = function(e){NULL})
    
    # Check if records
    if (any(c(is.null(glraw), is.null(career_raw)))) {
      sendSweetAlert(
        session, 
        title = "No Data",
        text = "No data available for this player in this season. 

        It's likely they were a rookie who didn't get gametime or were injured for the season. 

        It's possible an issues with encoding balkan names which I'm trying to fix ASAP sorry.",
        
        type = "error"
      )
      
      hide("loading-container", anim =TRUE)
      
    } else {
      
      # Update revals
      revals$career_raw = career_raw
      revals$gamelog_raw = glraw
      
      # Update team games log
      revals$team_log = build_team_log(career_raw, input$season)
      
      # Peer group
      starter_bench = ifelse(glraw %>% pull(min) %>% mean() > 26, "Starting", "Bench")
      
      position = 
        revals$player_master %>%
        filter(player_id == id_) %>%
        mutate(position_map = position_mapper(position)) %>%
        pull(position_map)
      
      peer_stats = get_peer_stats(revals$stats_master, revals$player_master, plyr_id = id_, starter_bench, position)
      
      # Add to revals
      revals$season = input$season
      revals$starter_bench = starter_bench
      revals$position = position
      revals$peer_stats_raw = peer_stats
      revals$player_name = input$player_name %>% str_to_upper() %>% str_c(".")
      
      
    }
    
  }) 
  
  # Build table observer
  observe({
    
    req(revals$career_raw)
    req(revals$player_id)
    req(revals$peer_stats_out)
    req(revals$stats_master)
    req(revals$player_master)
    
    player_overview_table = build_player_table(
      revals$player_id, 
      revals$stats_master, 
      revals$player_master, 
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
    
    # req(revals$efficiency_charts)
    req(revals$core_charts)
    req(revals$player_stat_table)
    
    show(selector = ".results-only", anim =TRUE)
    hide("loading-container", anim =TRUE)
    
  })
  

  
})








