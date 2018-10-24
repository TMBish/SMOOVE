response_to_df <- function(response, index = 1) {
  
  # Is it a NULL response
  if (is.null(response)) {
    return(tibble(ERROR = "TIMEOUT"))
  }
  
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
    tryCatch({
      httr::GET(
      api_url,
      add_headers(
        'Host' = 'stats.nba.com',
        'Proxy-Connection' = 'keep-alive',
        'User-Agent'= user_agent
      ),
      timeout(15)
    )
   }, error = function(e) {NULL})
  
  return(response)
  
}