response_to_df <- function(response, index = 1) {
  
  # Manipulate Response Object
  results = response %>%
    pluck("content") %>%
    rawToChar() %>%
    fromJSON() %>%
    pluck("resultSets")
  
  if (results %>% pluck("rowSet") %>% length() < index) {
    stop(glue("Response includes less than {index} items"))
  }
  

  # Empty?
  if (results$rowSet[[1]] %>% is_empty()) {
    return(tibble(ERROR = "NO RECORDS"))
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
  df = df %>% 
    type_convert(col_types = cols())
  
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



get_current_season <- function() {
  
  current_date = Sys.Date()
  current_year = lubridate::year(current_date)-1 ### CHANGE THISSSSS
  
  if (lubridate::month(current_date) > 6) {
    dte_string = paste0(current_year, "-", (current_year + 1)-2000)
  } else {
    dte_string = paste0(current_year - 1, "-", current_year-2000)
  }
  
  return(dte_string)
}