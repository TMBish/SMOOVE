# ++++++++++++++++++++++++
# Wrappers
# ++++++++++++++++++++++++

build_player_info <- function(season) {
  
  # Object name
  object_name = paste0("metadata/playerinfo/", season, ".rds")
  
  # Use get gcp rds utility
  player_info = get_gcp_rds(object_name)
  
  return(player_info)
  
}


build_player_stats <- function(season) {
  
  # Object name
  object_name = paste0("stats/leaguedashplayerstats/", season, ".rds")
  
  # Use get gcp rds utility
  stats_master = get_gcp_rds(object_name)
  
  return(stats_master)
  
}

build_team_log <- function(career_stats, season) {
  
  # Get career record of this season
  season_record = 
    career_stats %>% 
    filter(season_id == season)

  # Teams
  teams = season_record %>% filter(team_abbreviation != "TOT") %>% pull(team_id)

  # Pull gamelogs
  logs = 
    teams %>%
    map_dfr(function(x) {
      get_team_games(x, season) %>%
      arrange(game_id) %>%
      mutate(game_number = row_number())
    })
    
  return(logs)
  
}

# ++++++++++++++++++++++++
# Builders
# ++++++++++++++++++++++++

get_team_games <- function(team_id, season) {
  
  # Object name
  object_name = paste0("metadata/schedule/", season, "-", team_id, ".rds")
  
  # Use get gcp rds utility
  team_log = get_gcp_rds(object_name)
  
  return(team_log)
  
}
