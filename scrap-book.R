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


# Start some work --------------------------------------------------------------


# Get player
plyrid = get_player("Jimmy", "Butler")

# Get player gamelog
gl = get_player_gamelog(plyrid, season = "2017-18")

# Get all player stats
player_stats = get_all_player_stats(season = "2017-18")


# Get team list
teams = 
	submit_request("commonTeamYears", list('LeagueID' = '00')) %>%
	reponse_to_df(1) %>%
	filter(max_year==2018)


# Get rosters and positions
plan(multiprocess)
rosters = 
	teams %>%
	pull(team_id) %>%
	future_map(get_team_roster) %>%
  map(mutate_at, vars(num), as.character) %>%
	bind_rows() %>%
  select(-leagueid, -player, -birth_date)


# Join player stats and roster data
player_stats %>%
  inner_join(rosters, by = "player_id") %>%
  group_by(position) %>%
  summarise(n = n(), x = mean(pts))


# Get player career
bron_stats = get_player_career_stats(2544)

# Career Charts - One Example
chart_stat_career(bron_stats, "Three Point %")

# Career Charts - One Example
build_career_charts(bron_stats)



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



# All the api functions --------------------------------------------------------------

# Get player
plyrid = get_player("LeBron", "James")

# Get player gamelog
gamelog = get_player_gamelog(plyrid, season = "2017-18")

# Get all player stats - season averages for all players
player_stats = get_all_player_stats(season = "2017-18")

# Career stasts - players career stasts
career_stats = get_player_career_stats(plyrid)

player_master = build_player_data()



build_player_table(plyrid, player_stats, player_master, career_stats, TRUE)

