
if (!("pacman" %in% installed.packages())) install.packages('pacman')
library(pacman)

# Packages --------------------------------------------------------------

p_load_gh("ThomasSiegmund/shinyTypeahead")

p_load(
    tidyverse, purrr, glue, stringr, furrr,
    httr, jsonlite, zoo, assertthat, DT, highcharter, yaml, here, googleCloudStorageR,
    shiny, shinyWidgets, shinydashboard, shinyjs, shinythemes
)

# Options --------------------------------------------------------------

options(stringsAsFactors = FALSE)

# Default for shitty conflicted packages / functions
filter = dplyr::filter
lag = dplyr::lag
show = shinyjs::show
hide = shinyjs::hide

# Load in App Config
app_config = yaml.load_file("./data/config.yaml")

# Core vs Efficiency Fields
core_fields = app_config$`basic-stats` %>% keep(~ .$type == "core") %>% names()
efficiency_fields = app_config$`basic-stats` %>% keep(~ .$type == "efficiency") %>% names()

# Core functions
list.files("./utils/",pattern = "*.R$", full.names = TRUE) %>% map(source)

# Season
season = get_current_season()

# Enpoint? --------------------------------------------------------------

# Due to problems with the NBA stats API we can either:
#   a ) Point directly at the API (good for local instances of running this app)
#   b ) Point at my personal GCP Simple Storage snapshot (good for speed and remote instances)
# Obviously b) won't work if you're not me and don't have my GCP credentials that's why the default is a)

#app_endpoint = "nba-stats-api"
app_endpoint = "tmbish-gcp"

if (app_endpoint == "nba-stats-api") {

    # Load direct api utilities
    list.files("./utils/api/",pattern = "*.R$", full.names = TRUE) %>% map(source)
    
    # Hit api for player and season stats master
    # player_master = build_player_data()
    # stats_master = get_all_player_stats()
    player_master = read_rds("data/player_master.rds")
    stats_master = read_rds("data/stats_master.rds")
    
} else {
    
    # Load tmbish gcp utilities
    list.files("./utils/gcp/",pattern = "*.R$", full.names = TRUE) %>% map(source)
    
    # GCP Auth (HIDDEN FROM GIT)
    Sys.setenv("GCS_AUTH_FILE" = paste0(here(), "/gcp/tmbish-8998f7559de5.json"))
    options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/devstorage.full_control")
    gcs_auth()
    
    # Hit gcp for player and stats master
    player_master = build_player_info(season)
    stats_master = build_player_stats(season)
    
}



