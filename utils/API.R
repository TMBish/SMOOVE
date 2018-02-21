

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

get_current_season = function() {
    
    current_date = Sys.Date()
    current_year = lubridate::year(current_date)
    
    if (lubridate::month(current_date) > 6) {
        dte_string = paste0(current_year, "-", (current_year + 1)-2000)
    } else {
        dte_string = paste0(current_year - 1, "-", current_year-2000)
    }
    
    return(dte_string)
}

reponse_to_df <- function(response, index = 1) {
  
  # Manipulate Response Object
  results = response %>%
    pluck("content") %>%
    rawToChar() %>%
    fromJSON() %>%
    pluck("resultSets")
  
  if (results %>% pluck("rowSet") %>% length() < index) {
    stop(glue("Response includes less than {index} items"))
  }
  
  # Get the data
  df = results %>%
    pluck("rowSet") %>% 
    pluck(index) %>%
    as_tibble()
  
  # Get the columns  
  colnames = results %>%
    pluck("headers") %>% 
    pluck(index) %>%
    tolower()
  
  # Add Col Names
  df = setNames(df, colnames)
  
  # Auto Detect Data Types
  df = df %>% type_convert()
  
  return(df)
  
}

submit_request <- function(endpoint, params) {
    
    # To subsitute data
    url_build = 'http://stats.nba.com/stats/{endpoint}?{send_data}'
    # User agent in header
    user_agent = 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'
    
    # Parse Parameters into string
    send_data = 
        names(params) %>% 
            paste0("=", unlist(params)) %>%
            paste(collapse="&")

    # Build URL
    api_url = glue(url_build) %>% URLencode()
    
    
    response = 
      httr::GET(
        api_url,
        add_headers(
          'Host' = 'stats.nba.com',
          'Proxy-Connection' = 'keep-alive',
          'User-Agent'= user_agent
        )
      )
    
    return(response)

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
        'Season' = get_current_season(),
        'LeagueID' = '00', # ID for the NBA
        'IsOnlyCurrentSeason' = only_current_plyrs # 1 = only current
    )
    
    # Submit Request
    response = submit_request(endpoint, params)
    
    # Convert to dataframe
    df = reponse_to_df(response)
    
    return(df)
    
}

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
