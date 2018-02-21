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
