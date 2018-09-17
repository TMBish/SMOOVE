get_player_gamelog = function(season = NULL, playoffs = FALSE, per = "Per36") {
  
  # Params
  endpoint = 'leaguedashplayerstats'
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Playoffs
  season_type = ifelse(playoffs, "Playoffs", "Regular Season")
  
  # Assemble Params
  params = list(
    'Season' = season,
    'LeagueID' = '00', # ID for the NBA
    'SeasonType' = season_type,
    'PerMode' = 'Per36',
    'LastNGames' = 0,
    'MeasureType' = 'Base',
    'OpponentTeamID' = 0,
    'Month' = 0,
    'PlayerPosition' = 'Guard'
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = reponse_to_df(response, 1)
  
  return(df)
  
}