get_player_gamelog = function(player_id = NULL, season = NULL, playoffs = FALSE) {
  
  # Params
  endpoint = 'playergamelog'
  
  # Player ID
  if (is.null(player_id)) {
    stop("Player ID not provided")
  }
  
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
    'PlayerID' = player_id,
    'SeasonType' = season_type
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = reponse_to_df(response, 1)
  
  return(df)
  
}