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

# Load in App Config
app_config = yaml.load_file("./data/config.yaml")


# All the api functions --------------------------------------------------------------

# Get player
plyrid = get_player("Blake", "Griffin")

# Get player gamelog
gamelog = get_player_gamelog(plyrid, season = "2017-18")

# Get all player stats - season averages for all players
player_stats = get_all_player_stats(season = "2017-18")

# Career stasts - players career stasts
career_stats = get_player_career_stats(plyrid)

player_master = build_player_data()

build_player_table(plyrid, player_stats, player_master, career_stats, TRUE)





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

jitter = function(x) {
  
  rand_sign = sample(c(1,-1), size = length(x), replace = TRUE)
  
  rescaled_x = abs((x-mean(x)) / sd(x))
  rescaled_x = round(rescaled_x * 2)
  rescaled_x = case_when(
    rescaled_x < 0.2 ~ 0.2,
    TRUE ~ rescaled_x
  )
  
  
  rescaled_x %>%
    map_dbl(~runif(1, min = -1/., max = 1/.))
    
}


stats_master %>% 
  filter(min > 20) %>%
  select(player_name, "value" = pts) %>%
  mutate(
    y_jitter = jitter(value)
  ) %>%
  hchart("scatter", hcaes(x = value, y = y_jitter))
  
  pull(pts) %>% 
  hchart() %>% 
  hc_add_theme(hc_theme_smoove()) %>%
  hc_plotOptions(
    column = list(borderColor = "#000", borderWidth = 4)
  )

hcboxplot(x = stats_master$pts, name = "Length", color = "#2980b9") %>%
  hc_add_series("scatter", tibble(x = 21), hcaes(y = x))



