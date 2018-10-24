# ++++++++++++++++++++++++
# Wrappers
# ++++++++++++++++++++++++

build_player_data <- function(season = NULL) {
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Set up parallel processing
  plan(multiprocess)
  
  # Get list of team ids
  teams = get_team_list()
  
  # Get team rosters from Team IDs
  rosters = teams %>%
    pull(team_id) %>%
    future_map(~get_team_roster(., season = season)) %>%
    bind_rows()
    
    
  return(rosters)
  
}

build_team_log <- function(career_stats, season = "2017-18") {

  # Get career record of this season
  season_record = 
    career_stats %>% 
    filter(season_id == season)

  # Teams
  teams = season_record %>% filter(team_abbreviation != "TOT") %>% pull(team_id)

  # Pull gamelogs
  plan(multiprocess)
  logs = 
    teams %>%
    future_map_dfr(function(x) {
      get_team_games(x) %>%
      arrange(game_id) %>%
      mutate(game_number = row_number())
    })

  return(logs)

}


# ++++++++++++++++++++++++
# Builders
# ++++++++++++++++++++++++

get_team_list <- function() {
  
  # Params
  endpoint = "commonTeamYears"
  league_id = "00"
  
  # Submit
  submit_request(endpoint, list("LeagueID" = "00")) %>%
    response_to_df(1) %>%
    filter(max_year == 2018) %>%
    return()
    
}

get_team_roster <- function(team_id, season = NULL) {
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Params
  endpoint = 'commonteamroster'
  
  # Assemble Params
  params = list(
    'Season' = season,
    'TeamID' = team_id
  )
  
  # Execute
  submit_request(endpoint, params) %>%
    response_to_df(1) %>%
    mutate_at(vars(num, exp), as.character) %>%
    select(-leagueid, -birth_date) %>%
    return()
  
}

get_team_games <- function(team_id, season = NULL) {
  
  # Params
  endpoint = 'teamgamelog'
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Assemble Params
  params = list(
    'Season' = season,
    'TeamID' = team_id,
    'SeasonType' = "Regular Season"
  )
  
  # Execute
  submit_request(endpoint, params) %>%
    response_to_df(1) %>%
    select(team_id, game_id, game_date) %>%
    return()
  
}


get_all_players <- function(season = NULL, only_current_plyrs = 1) {
  
  # Params
  endpoint = 'commonallplayers'
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Assemble Params
  params = list(
    'Season' = season,
    'LeagueID' = '00', # ID for the NBA
    'IsOnlyCurrentSeason' = only_current_plyrs # 1 = only current
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert to dataframe
  df = response_to_df(response, 1)
  
  return(df)
  
}

get_player <- function(first_name, last_name, id_only = TRUE) {
  
  first_name = first_name %>% str_trim() %>% str_to_lower()
  last_name = last_name %>% str_trim() %>% str_to_lower()
  
  # Get All Players
  players = get_all_players(only_current_plyrs = 0)
  
  # Filter
  plyr = players %>%
    filter(str_to_lower(display_first_last) == paste(first_name, last_name))
  
  if (id_only) {
    
    return(plyr %>% pull(person_id))
    
  } else {
    
    return(plyr)
    
  }
  
}


get_player_info <- function(player_id) {
  
  # Params
  endpoint = 'commonplayerinfo'

  # Assemble Params
  params = list(
    'PlayerID' = player_id
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = response_to_df(response, 1)
  
  return(df)
  
}