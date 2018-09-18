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
rosters = 
	teams %>%
	pull(team_id) %>%
	map(get_team_roster) %>%
	bind_rows()

# Testing an API endpoint --------------------------------------------------------------

# Params
endpoint = 'commonteamroster'

# Assemble Params
params = list(
	'Season' = "2017-18",
	# 'LeagueID' = '00', # ID for the NBA
	# 'IsOnlyCurrentSeason' = 1
	#'PlayerID' = plyrid,
	'TeamID' = '1610612750'
)

# Submit Request
response = submit_request(endpoint, params)

# Convert first element of response to DF
df = reponse_to_df(response, 1)
