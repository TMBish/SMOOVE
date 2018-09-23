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
library(shinyTypeahead)

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

# Initialise Data --------------------------------------------------------------

# player_master = build_player_data()
# write_rds(player_master, "data/player_master.rds")
player_master = read_rds("data/player_master.rds")

# stats_master = get_all_player_stats(season = "2017-18", per_mode = "PerGame")
# write_rds(stats_master, "data/stats_master.rds")
stats_master = read_rds("data/stats_master.rds")