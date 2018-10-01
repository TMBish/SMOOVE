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

get_peer_median <- function(stats_master, stat_name, starter_bench = "Starting", plyr_position = "F") {
  
  # Get field config from app config list in parent environment
  conf_item = 
    app_config %>% 
    pluck("basic-stats", stat_name)
  
  # Get real col header name from config
  col = conf_item %>% pluck("col") 
  
  # Peer group
  game_cutoff = stats_master %>% summarise(cutoff = round(max(gp) * 0.3)) %>% pull(cutoff) # 30% of games
  if (starter_bench == "Starting") {min_boolean=stats_master$min >= 28} else {min_boolean=stats_master$min < 28}
  
  # Return Median
  stats_master[min_boolean,] %>% 
    inner_join(player_master %>% select(position, player_id), by = "player_id")
    # Games Played
    filter(gp >= game_cutoff) %>%
    # Position
    mutate(position_map = position_mapper(position)) %>%
    filter(position_map == plyr_position) %>%
    select(value = !!col) %>%
    pull(value) %>%
    median() %>%
    return()
  
}

get_peer_stats <- function(stats_master, player_master, starter_bench = "Starting", plyr_position = "F") {
  
  # Peer group criteria
  game_cutoff = 
    stats_master %>% 
    summarise(cutoff = round(max(gp) * 0.3)) %>% 
    pull(cutoff) # Need to have played 30% of games
  
  # Starter bench
  if (starter_bench == "Starting") {
    min_boolean=stats_master$min >= 26
  } else if (starter_bench == "Bench") {
    min_boolean=stats_master$min < 26
  } else {
    min_boolean = rep(TRUE, nrow(stats_master))
  }
  
  stats_master[min_boolean,] %>%
    filter(gp >= game_cutoff) %>%
    # Position
    inner_join(player_master %>% select(player_id, position), by = "player_id") %>%
    mutate(position_map = position_mapper(position)) %>%
    filter(position_map == plyr_position) %>%
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




