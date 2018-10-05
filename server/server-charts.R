# ++++++++++++++++++++++++
# CHART BUILD OBSERVER
# ++++++++++++++++++++++++

# CORE CHART BUILDER
observe({
  
  req(revals$player_id)
  req(revals$gamelog_out)
  req(revals$career_out)
  req(revals$peer_stats_out)
  req(revals$team_log)
  
  # Stat name & per mode
  stat_name = input$core_stat_type
  per_mode = isolate({per_mode_translation(input$per_36_enable)})
  
  # Output
  output = list()
  
  # Build season chart
  output$season_chart = build_season_chart(
    game_log = revals$gamelog_out,
    team_log = revals$team_log,
    peer_stats = revals$peer_stats_out,
    stat_name = stat_name,
    per_mode = per_mode
  )
  
  # Build career chart
  output$career_chart = build_career_chart(
    career_log = revals$career_out,
    peer_stats = revals$peer_stats_out,
    stat_name = stat_name,
    per_mode = per_mode
  )
  
  # Build distribution chart
  output$distribution_chart =  build_distribution_chart(
    player_id = revals$player_id,
    peer_stats = revals$peer_stats_out,
    stat_name = stat_name,
    per_mode = per_mode
  )
  
  # Place back in revals
  revals$core_charts = output

})


# EFFICIENCY CHART BUILDER
observe({
  
  req(revals$player_id)
  req(revals$gamelog_out)
  req(revals$career_out)
  req(revals$peer_stats_out)
  req(revals$team_log)
  
  # Stat name & per mode
  stat_name = input$efficiency_stat_type
  per_mode = isolate({per_mode_translation(input$per_36_enable)})
  
  # Output
  output = list()
  
  # Build season chart
  output$season_chart = build_season_chart(
    game_log = revals$gamelog_out,
    team_log = revals$team_log,
    peer_stats = revals$peer_stats_out,
    stat_name = stat_name,
    per_mode = per_mode
  )
  
  # Build career chart
  output$career_chart = build_career_chart(
    career_log = revals$career_out,
    peer_stats = revals$peer_stats_out,
    stat_name = stat_name,
    per_mode = per_mode
  )
  
  # Build distribution chart
  output$distribution_chart =  build_distribution_chart(
    player_id = revals$player_id,
    peer_stats = revals$peer_stats_out,
    stat_name = stat_name,
    per_mode = per_mode
  )
  
  # Place back in revals
  revals$efficiency_charts = output

})


# ++++++++++++++++++++++++
# CORE STATS
# ++++++++++++++++++++++++

# Season
output$core_season = renderHighchart({
  
  req(revals$core_charts)
  revals$core_charts$season_chart
  
})

# Career
output$core_career = renderHighchart({
  
  req(revals$core_charts)
  revals$core_charts$career_chart
  
})

# Peer Distribution
output$core_distribution = renderHighchart({
  
  req(revals$core_charts)
  revals$core_charts$distribution_chart
  
})

# ++++++++++++++++++++++++
# EFFICIENCY STATS
# ++++++++++++++++++++++++

# Season
output$efficiency_season = renderHighchart({
  
  req(revals$efficiency_charts)
  revals$efficiency_charts$season_chart
  
})

# Career
output$efficiency_career = renderHighchart({
  
  req(revals$efficiency_charts)
  revals$efficiency_charts$career_chart
  
})

# Efficiency
output$efficiency_distribution = renderHighchart({
  
  req(revals$efficiency_charts)
  revals$efficiency_charts$distribution_chart
  
})