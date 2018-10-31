library(pacman)

p_load(
  tidyverse, purrr, glue, stringr, furrr,
  httr, jsonlite, zoo, assertthat, DT, highcharter, yaml,
  shiny, shinyWidgets, shinydashboard, shinyjs, shinythemes,
  here, googleCloudStorageR, R.utils
)


# OPTIONS AND FUNCTIONS -----------------------------------------------------------------

# Defaults
filter = dplyr::filter
lag = dplyr::lag
show = shinyjs::show
hide = shinyjs::hide


# Season
season = "2018-19"

# Functions
sapply(list.files("./utils/", pattern = "*.R$", full.names = TRUE),source)
sapply(list.files("./utils/api/", pattern = "*.R$", full.names = TRUE),source)

# GCP AUTH
Sys.setenv("GCS_AUTH_FILE" = "C:/Data/SECRETS/tmbish-8998f7559de5.json")
options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/devstorage.full_control")
gcs_auth()


# ONE OFF -----------------------------------------------------------------

# Teams
team_list = get_team_list()
# team_list_file_name = "team-lookup.rds"
# write_rds(team_list, paste0("gcp/",team_list_file_name))
# gcs_upload(
#   file = paste0("gcp/", team_list_file_name),
#   bucket = "smoove",
#   name = paste0("metadata/",team_list_file_name)
# )

# DAILY -----------------------------------------------------------------


# Team Schedule
current_teams = team_list %>% filter(max_year == 2018)
for (team_id in current_teams$team_id) {
  
  team_log = get_team_games(team_id, season = season)
  
  team_log_name = glue("{team_id}.rds")
  write_rds(team_log, paste0("gcp/",team_log_name))
  gcs_upload(
    file = paste0("gcp/", team_log_name),
    bucket = "smoove",
    name = paste0("metadata/schedule/",season,"-",team_id,".rds")
  )
  file.remove(paste0("gcp/",team_log_name))
} 



# Player master
player_info = build_player_data(season=season)
#player_info = read_rds("data/player_master.rds")
player_info_file_name = glue("{season}-player-info.rds")
write_rds(player_info, paste0("gcp/",player_info_file_name))
gcs_upload(
  file = paste0("gcp/", player_info_file_name),
  bucket = "smoove",
  name = paste0("metadata/playerinfo/",season, ".rds")
)

# League dash player stats
leaguedashplayerstats = get_all_player_stats(season = season, per_mode = "PerGame")
leaguedashplayerstats_file_name = glue("{season}-leaguedashplayerstats.rds")
write_rds(leaguedashplayerstats, paste0("gcp/",leaguedashplayerstats_file_name))
gcs_upload(
  file = paste0("gcp/", leaguedashplayerstats_file_name),
  bucket = "smoove",
  name = paste0("stats/leaguedashplayerstats/",season,".rds")
)


# Multisession map
library(furrr)

plan(multisession)


res = future_map(
  .x = player_info$player_id, 
  .f = function(x) {
    
    career_stats = get_player_career_stats(x)
    
    if ("ERROR" %in% names(career_stats)) {
      return()
    } else {
      career_stats_file_name = glue("{x}.rds")
      write_rds(career_stats, paste0("gcp/",career_stats_file_name))
      gcs_upload(
        file = paste0("gcp/", career_stats_file_name),
        bucket = "smoove",
        name = paste0("stats/playercareerstats/",x,".rds")
      )
      file.remove(paste0("gcp/",career_stats_file_name))
    }
  })


# Career Stats
# counter = 0
# for (player_id in player_info$player_id) {
#   
#   counter = counter + 1
#   
#   career_stats = NULL
#   
#   while (!is.data.frame(career_stats)) {
#     
#     career_stats = get_player_career_stats(player_id)
#     
#     if ("ERROR" %in% names(career_stats)) {
#       
#       if (career_stats$ERROR[1] == "NO RECORDS") {
#         break
#       } else {
#         print("SLEEPING")
#         Sys.sleep(30)
#       }
#       
#       # Else was a timeout so continue
#       
#     }
#     
#   }
#   
#   if ("ERROR" %in% names(career_stats)) {
#     next
#   }
#   
#   career_stats_file_name = glue("{player_id}.rds")
#   
#   write_rds(career_stats, paste0("gcp/",career_stats_file_name))
#   
#   gcs_upload(
#     file = paste0("gcp/", career_stats_file_name),
#     bucket = "smoove",
#     name = paste0("stats/playercareerstats/",player_id,".rds")
#   )
#   
#   file.remove(paste0("gcp/",career_stats_file_name))
#   
# }

# Multi session map
res = future_map(
  .x = player_info$player_id, 
  .f = function(x) {
    
    gamelog = get_player_gamelog(x, season = season)
    
    if ("ERROR" %in% names(gamelog)) {
      return()
    } else {
      gamelog_file_name = glue("{x}.rds")
      write_rds(gamelog, paste0("gcp/",gamelog_file_name))
      gcs_upload(
        file = paste0("gcp/", gamelog_file_name),
        bucket = "smoove",
        name = paste0("stats/playergamelog/",season, "-", x,".rds")
      )
      file.remove(paste0("gcp/",gamelog_file_name))
    }
  })


# Player gamelog
# counter = 0
# for (player_id in player_info$player_id) {
# 
#   gamelog = NULL
#   
#   while (!is.data.frame(gamelog)) {
#     
#     gamelog = get_player_gamelog(player_id, season = season)
#     
#     if ("ERROR" %in% names(gamelog)) {
#       
#       if (gamelog$ERROR[1] == "NO RECORDS") {
#         break
#       } else {
#         print("SLEEPING")
#         Sys.sleep(120)
#       }
#       # Else was a timeout so continue
#       
#     }
#     
#   }
#   
#   if ("ERROR" %in% names(gamelog)) {
#     next
#   }
#   
#   gamelog_file_name = glue("{player_id}.rds")
#   write_rds(gamelog, paste0("gcp/",gamelog_file_name))
#   gcs_upload(
#     file = paste0("gcp/", gamelog_file_name),
#     bucket = "smoove",
#     name = paste0("stats/playergamelog/",season, "-", player_id,".rds")
#   )
#   file.remove(paste0("gcp/",gamelog_file_name))
# }


