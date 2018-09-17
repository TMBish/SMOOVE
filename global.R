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