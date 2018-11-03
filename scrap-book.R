library(tidyverse)
library(shiny)
library(shinyWidgets)
library(DT)
library(highcharter)
library(shinydashboard)
library(yaml)
library(zoo)
library(highcharter)
library(httr)
library(jsonlite)
library(purrr)
library(glue)
library(stringr)
library(assertthat)
library(furrr)

options(stringsAsFactors = FALSE)

# Config
app_title = "NBA Pocketbook"

# Defaults
filter = dplyr::filter
lag = dplyr::lag

# Load Utils --------------------------------------------------------------
sapply(list.files("./utils/", pattern = "*.R$", full.names = TRUE),source)
list.files("./utils/gcp/",pattern = "*.R$", full.names = TRUE) %>% map(source)

list.files("./utils/api/",pattern = "*.R$", full.names = TRUE) %>% map(source)

# Load in App Config
app_config = yaml.load_file("./data/config.yaml")


# All the api functions --------------------------------------------------------------


    player_master = build_player_info('2018-19')
    stats_master = build_player_stats('2018-19')

# Get player
plyrid = get_player("Blake", "Griffin")

# Get player gamelog
game_log = get_player_gamelog(plyrid, season = "2017-18")

# Get all player stats - season averages for all players
#player_stats = get_all_player_stats(season = "2017-18")

# Career stasts - players career stasts
career_stats = get_player_career_stats(plyrid)

# Team log
team_log = build_team_log(career_stats)

# Peer stats
peer_stats = get_peer_stats(stats_master, player_master, "Both", "F")

# Misc
stat_name = "Points"
per_mode = "Per 36"



#player_master = build_player_data()

player_table = build_player_table(plyrid, player_stats, player_master, career_stats, TRUE)

build_season_chart(gamelog, team_log, peer_stats, stat_name, per_mode)





# Testing an API endpoint --------------------------------------------------------------

# Params
endpoint = 'playercareerstats'

# Assemble Params
params = list(
	'Season' = "2017-18",
	 'LeagueID' = '00', # ID for the NBA
	'PerMode' = 'Per36',
	# 'IsOnlyCurrentSeason' = 1
	'PlayerID' = "2544"
	#'TeamID' = '1610612750'
)

# Submit Request
response = submit_request(endpoint, params)

# Convert first element of response to DF
df = response_to_df(response, 1)



# Playing around with the distribution function --------------------------------------------------------------

smoove_jitter = function(x) {
  
  
  # CDF
  cdf = dnorm(x, mean = mean(x), sd = sd(x))
  #y = abs(cdf-0.5) * 2
  
  (cdf %>%
    map_dbl(~runif(1, 0, .)) ) 
  #* sample(c(-1,1), size = length(x), replace = TRUE)
  

  #return(cdf)
    
}


name_ = "Paul George"

# d_f = stats_master %>% 
#   inner_join(player_master %>% select(player_id, position), by = "player_id") %>%
#   mutate(position_map = position_mapper(position)) %>%
#   filter(min > 28, gp > 30, position == "G") %>%
#   select(player_name, "value" = pts) %>%
#   mutate(
#     y_jitter = 1,
#       #smoove_jitter(value),
#     colour = ifelse(player_name == name_, 1, 0)
#   ) %>%
#   mutate(
#     hctooltip = glue("<b> {player_name} </b> <br> Points Per Game: {value}")
#   )
# 
# hchart(d_f %>% filter(colour == 0), "scatter", hcaes(x = value, y = y_jitter), color = "grey") %>%
#   hc_add_series(d_f %>% filter(colour==1), "scatter", hcaes(x = value, y = y_jitter), color = "#ED074F", marker = list(radius = 5)) %>%
#   hc_add_theme(hc_theme_smoove()) %>%
#   hc_yAxis(
#     title = list(text = ""),
#     gridLineWidth = 0,
#     lineWidth = 0,
#     #min = -0.0001,
#     labels = list(enabled = FALSE)
#   ) %>%
#   hc_tooltip(
#     useHTML = TRUE,
#     formatter = JS("function(){return(this.point.hctooltip)}")
#   )
  
  
d_f = stats_master %>% 
  inner_join(player_master %>% select(player_id, position), by = "player_id") %>%
  mutate(position_map = position_mapper(position)) %>%
  filter(min > 26, gp > 30, position == "F") %>%
  select(player_name, "value" = pts) %>%
  mutate(
    bucket = round(value / 2) * 2,
    colour = ifelse(player_name == name_, 1, 0)
  ) %>%
  group_by(bucket) %>%
  mutate(y =  dense_rank(value)) %>%
  ungroup() %>%
  mutate(
    hctooltip = glue("<b> {player_name} </b> <br> Points Per Game: {value}")
  )


hchart(
  d_f %>% filter(colour == 0), "scatter", hcaes(x = bucket, y = y), 
  marker = list(radius = 6, symbol = "square"), color = "grey"
  ) %>%
  hc_add_series(d_f %>% filter(colour==1), "scatter", hcaes(x = bucket, y = y), color = "#ED074F", marker = list(radius = 6, symbol = "square")) %>%
  hc_add_theme(hc_theme_smoove()) %>%
  hc_yAxis(
    title = list(text = ""),
    gridLineWidth = 0,
    lineWidth = 0,
    #min = -0.0001,
    labels = list(enabled = FALSE)
  ) %>%
  hc_tooltip(
    useHTML = TRUE,
    formatter = JS("function(){return(this.point.hctooltip)}")
  )

