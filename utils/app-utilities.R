gamelog_to_perM <- function(gl, M = 36) {
  
  # Turn a gamelog dataset into per36 numbers
  gl %>%
    mutate_at(
      .vars = vars(-(season_id:min), -contains("pct"), -video_available, -season), 
      .funs = funs(round(. * M / min, 2))
    )
  
}

career_to_perM <- function(cr, M = 36) {
  
  # Turn career stats dataset into per36 numbers
  cr %>%
    mutate_at(
      .vars = vars(-(player_id:min), -contains("pct")), 
      .funs = funs(round(. * M / min, 2))
    )
  
}

allplayerstats_to_perM <- function(cr, M = 36) {
  
  # Turn career stats dataset into per36 numbers
  cr %>%
    mutate_at(
      .vars = vars(-(player_id:min), -contains("pct"), -(nba_fantasy_pts:cfparams)), 
      .funs = funs(round(. * M / min, 2))
    )
  
}


