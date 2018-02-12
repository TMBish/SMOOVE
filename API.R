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

get_league()


submit_request <- function(endpoint, params) {
    
    # referer = ifelse(player_stats, 'player', 'scores')
    # base_url = glue('http://stats.nba.com/stats/{referer}/')
    url_build = 'http://stats.nba.com/stats/{endpoint}/{send_data}'
    user_agent = 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36'
    
    # Parse Params
    send_data = 
        names(params) %>% 
            paste0("=", unlist(params)) %>%
            paste(collapse="&")

    api_url = glue(url_build) %>% URLencode()
    
    json_response = httr::GET(
                  api_url,
                  add_headers(
                    'Host' = 'stats.nba.com',
                    'Proxy-Connection' = 'keep-alive',
                    'User-Agent'= user_agent
                  )
                )
    
    # Do stuff with JSON
    
    
    return()

}

get_players = function(first_name = NULL, last_name = NULL, all_players = FALSE, season = NULL) {
    
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
        'IsOnlyCurrentSeason' = 0 # Not only current players
    )
    
    # Submit Request
    response = submit_request(endpoint, params)
    
    
}

get_player_info = function(first_name, last_name, seasons = NULL) {
    
    if (seasons %>% is.null()) {
        seasons = get_current_season()
    }
    
    
}
