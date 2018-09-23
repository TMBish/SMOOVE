


get_team_roster = function(team_id) {
  
  # Params
  endpoint = 'commonteamroster'
  
  # Assemble Params
  params = list(
    'Season' = "2017-18",
    'TeamID' = team_id
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = reponse_to_df(response, 1)
  
  return(df)
  
}


get_all_players = function(season = NULL, only_current_plyrs = 1) {
  
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
  df = reponse_to_df(response)
  
  return(df)
  
}

get_player = function(first_name, last_name, id_only = TRUE) {
  
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
