gamelog_to_perM <- function(gl, M = 36) {
  
  # Turn a gamelog dataset into per36 numbers
  gl %>%
    mutate_at(
      .vars = vars(-(season_id:min), -contains("pct"), -video_available, -season), 
      .funs = funs(round(. * M / min, 1))
    )
  
}

career_to_perM <- function(cr, M = 36) {
  
  # Turn career stats dataset into per36 numbers
  cr %>%
    mutate_at(
      .vars = vars(-(player_id:min), -contains("pct")), 
      .funs = funs(round(. * M / min, 1))
    )
  
}

allplayerstats_to_perM <- function(cr, M = 36) {
  
  # Turn career stats dataset into per36 numbers
  cr %>%
    mutate_at(
      .vars = vars(-(player_id:min), -contains("pct"), -(nba_fantasy_pts:cfparams)), 
      .funs = funs(round(. * M / min, 1))
    )
  
}

get_peer_median <- function(stats_master, stat_name) {
  
  # Get field config from app config list in parent environment
  conf_item = app_config %>% pluck("basic-stats", stat_name)
  
  # Get real col header name from config
  col = conf_item %>% pluck("col") 
  
  # Return Median
  stats_master %>% 
    filter(min > 10) %>%
    select(value = !!col) %>%
    pull(value) %>%
    median() %>%
    return()
  
}

# Get career average
get_career_average = function(career_stats, per36 = FALSE) {
  
  # This is anoyying cause there's no "Career average" record in the career stats, only individual seasons
  # And it's not ok to take an average of an average
  # So we'll have to be clever by converting to totals and then standardising
  
  # Here's the per game calculation
  if (!per36) {
    career_stats %>%
      # Convert to totals
      mutate_at(
        .vars = vars(-(player_id:gs), -contains("pct")), 
        .funs = funs(round(. * gp, 0))
      ) %>%
      # Drop the season information
      select(-(player_id:player_age), -gs) %>%
      # Calculate Totals
      summarise_all(
        sum
      ) %>%
      # Re-assign efficiency fields
      mutate(
        fg_pct = fgm / fga,
        fg3_pct = fg3m / fg3a,
        ft_pct = ftm / fta
      ) %>%
      # Caclulate the per game averages
      mutate_at(
        .vars = vars(-gp, -contains("pct")), 
        .funs = funs(round(. / gp, 1))
      ) %>%
      select(-gp)

  } else {
    # Here's the per 36 calculation
    career_stats %>%
      # Convert to totals
      mutate_at(
        .vars = vars(-(player_id:gs), -contains("pct")), 
        .funs = funs(round(. * gp, 0))
      ) %>%
      # Drop the season information
      select(-(player_id:player_age), -gs, -gp) %>%
      # Calculate Totals
      summarise_all(
        sum
      ) %>%
      # Re-assign efficiency fields
      mutate(
        fg_pct = fgm / fga,
        fg3_pct = fg3m / fg3a,
        ft_pct = ftm / fta
      ) %>%
      # Caclulate the per game averages
      mutate_at(
        .vars = vars(-min, -contains("pct")), 
        .funs = funs(round(. * 36 / min, 1))
      ) %>%
      mutate(min = 36)
    
  }
  
}




