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
