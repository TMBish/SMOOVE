get_all_player_stats = function(
  season = NULL, 
  playoffs = FALSE, 
  per_mode = "Per36",
  player_position = NULL,
  from_date = NULL,
  to_date = NULL
) {
  
  # Params
  endpoint = 'leaguedashplayerstats'
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Playoffs
  season_type = ifelse(playoffs, "Playoffs", "Regular Season")
  
  # Per
  assert_that(str_detect(per_mode,"(Totals)|(PerGame)|(Per36)|(PerPossession)|(Per100Possessions)"))
  
  # Position
  if (is.null(player_position)) {
    player_position = ''
  } else {
    assert_that(str_detect(player_position,"((F)|(C)|(G)|(C-F)|(F-C)|(F-G)|(G-F))"))
  }
  
  # Date boundaries
  if (is.null(from_date)) {from_date = ''}
  if (is.null(to_date)) {to_date = ''}
  
  # Assemble Params
  params = list(
    'Season' = season,
    'LeagueID' = '00', # ID for the NBA
    'SeasonType' = season_type,
    'PerMode' = per_mode, # (Totals)|(PerGame)|(MinutesPer)|(Per48)|(Per40)|(Per36)|(PerMinute)|(PerPossession)|(PerPlay)|(Per100Possessions)|(Per100Plays)
    'LastNGames' = 0,
    'MeasureType' = 'Base',
    'OpponentTeamID' = 0,
    'Month' = 0,
    'PlayerPosition' = '', #((F)|(C)|(G)|(C-F)|(F-C)|(F-G)|(G-F))
    'GameScope' = '',
    'PlayerExperience' = '', # ((Rookie)|(Sophomore)|(Veteran))
    'StarterBench' = '',
    'PlusMinus' = 'N',
    'PaceAdjust' = 'N',
    'Rank' = 'N',
    'Outcome' = '',
    'Location' = '',
    'SeasonSegment' = '',
    'DateFrom' = from_date, # "YYYY-MM-DD"
    'DateTo' = to_date, # "YYYY-MM-DD"
    'VsConference' = '',
    'VsDivision' = '',
    'GameSegment' = '',
    'Period' = 0
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = reponse_to_df(response, 1)
  
  # Remove rank columns as they bloat the table
  df = df %>% select(-matches("rank$"))
  
  return(df)
  
}