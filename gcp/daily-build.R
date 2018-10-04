library(pacman)

p_load(
  tidyverse, purrr, glue, stringr, furrr,
  httr, jsonlite, zoo, assertthat, DT, highcharter, yaml,
  shiny, shinyWidgets, shinydashboard, shinyjs, shinythemes,
  here, googleCloudStorageR
)


# OPTIONS AND FUNCTIONS -----------------------------------------------------------------

# Season
season = "2017-18"

# Functions
sapply(list.files("./utils/", pattern = "*.R$", full.names = TRUE),source)

# GCP AUTH
Sys.setenv("GCS_AUTH_FILE" = paste0(here(), "/gcp/tmbish-8998f7559de5.json"))
options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/devstorage.full_control")
gcs_auth()


# ONE OFF -----------------------------------------------------------------




# DAILY -----------------------------------------------------------------


# Player master
player_info = build_player_data()
player_info_file_name = glue("{season}-player-info.rds")
write_rds(player_info, paste0("gcp/",player_info_file_name))
gcs_upload(
  file = paste0("gcp/", player_info_file_name),
  bucket = "smoove",
  name = paste0("metadata/",player_info_file_name)
)

# League dash player stats
leaguedashplayerstats = get_all_player_stats(season = season)
leaguedashplayerstats_file_name = glue("{season}-leaguedashplayerstats.rds")
write_rds(leaguedashplayerstats, paste0("gcp/",leaguedashplayerstats_file_name))
gcs_upload(
  file = paste0("gcp/", leaguedashplayerstats_file_name),
  bucket = "smoove",
  name = paste0("stats/leaguedashplayerstats/",season,".rds")
)

# Career Stats
counter = 0
for (player_id in player_info$player_id) {
  
  counter = counter + 1
  
  if (counter %% 100 == 0) {
    print("SLEEP")
    Sys.sleep(30)
  }
  
  print(counter)
  
  
  career_stats = tryCatch({
    get_player_career_stats(player_id)
  }, error = function(e){
    # A rookie
    NA
  })
  
  if (!is.data.frame(career_stats)) {next}
  
  career_stats_file_name = glue("{player_id}.rds")
  write_rds(career_stats, paste0("gcp/",career_stats_file_name))
  gcs_upload(
    file = paste0("gcp/", career_stats_file_name),
    bucket = "smoove",
    name = paste0("stats/playercareerstats/",player_id,".rds")
  )
  file.remove(paste0("gcp/",career_stats_file_name))
}


# Player gamelog
counter = 0
for (player_id in player_info$player_id) {
  
  counter = counter + 1
  
  if (counter %% 30 == 0) {
    print("SLEEP")
    Sys.sleep(30)
  }
  
  print(counter)
  
  
  gamelog = tryCatch({
    get_player_gamelog(player_id, season = season)
  }, error = function(e){
    # A rookie
    NA
  })
  
  if (!is.data.frame(gamelog)) {next}
  
  gamelog_file_name = glue("{player_id}.rds")
  write_rds(gamelog, paste0("gcp/",gamelog_file_name))
  gcs_upload(
    file = paste0("gcp/", gamelog_file_name),
    bucket = "smoove",
    name = paste0("stats/playergamelog/",player_id,".rds")
  )
  file.remove(paste0("gcp/",gamelog_file_name))
}


