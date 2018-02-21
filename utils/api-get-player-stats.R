get_player_stats = function(player_id = NULL, season = NULL) {
  
  # Params
  endpoint = 'commonplayerinfo'
  
  # Player ID
  if (is.null(player_id)) {
    stop("Player ID not provided")
  }
  
  # Season
  if (is.null(season)) {
    season = get_current_season()
  }
  
  # Assemble Params
  params = list(
    'Season' = season,
    'LeagueID' = '00', # ID for the NBA
    'PlayerID' = player_id # Not only current players
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Turn to DF
  results = response %>%
    pluck("content") %>%
    rawToChar() %>%
    fromJSON() %>%
    pluck("resultSets")
  
  df_1 = results %>%
    pluck("rowSet") %>% 
    pluck(1) %>%
    as_tibble()
  
  colnames_1 = results %>%
    pluck("headers") %>% 
    pluck(1) %>%
    tolower()
  
  df_1 = setNames(df_1, colnames_1)
  
  df_2 = results %>%
    pluck("rowSet") %>% 
    pluck(2) %>%
    as_tibble()
  
  colnames_2 = results %>%
    pluck("headers") %>% 
    pluck(2) %>%
    tolower()
  
  df_2 = setNames(df_2, colnames_2)
  
  
  df_2 = results %>%
    pluck("rowSet") %>% 
    pluck(3) %>%
    as_tibble()
  
  colnames_2 = results %>%
    pluck("headers") %>% 
    pluck(3) %>%
    tolower()
  
  df_2 = setNames(df_2, colnames_2)
  
  return(df)
  
}