# ++++++++++++++++++++++++
# Wrappers
# ++++++++++++++++++++++++

get_player_career_stats <- function(player_id) {
  
  # Object name
  object_name = paste0("stats/playercareerstats/", player_id, ".rds")
  
  # Use get gcp rds utility
  career_stats = get_gcp_rds(object_name)
  
  return(career_stats)
  
}


get_player_gamelog <- function(player_id, season) {
  
  # Object name
  object_name = paste0("stats/playergamelog/", player_id, ".rds")
  
  # Use get gcp rds utility
  game_log = get_gcp_rds(object_name)
  
  return(game_log)
  
}


