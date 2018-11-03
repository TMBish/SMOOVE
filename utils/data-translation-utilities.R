per_mode_translation = function(per36) {
  
  ifelse(per36, "Per 36", "Per Game")
  
}

data_stat_translation = function(stat_name) {
  
  recode(stat_name,
        min = "Minutes",
        pts = "Points",
        reb = "Rebounds",
        ast = "Assists",
        fg_pct = "FG %",
        fg3_pct = "3PT %",
        ft_pct = "FT %",
        fga = "FG Attempts",
        fgm = "FG Makes",
        fg3a = "3PT Attempts",
        fg3m = "3PT Makes",
        fta = "FT Attempts",
        ftm = "FT Makes",
        stl = "Steals",
        blk = "Blocks",
        tov = "Turnovers",
        fga = "FGA",
        fg3a = "3PA",
        fta = "FTA",
        oreb = "Off Rebounds",
        dreb = "Def Rebounds"
  )
  
}


table_data_stat_translation = function(stat_name) {
  
  recode(stat_name,
        min = "Minutes",
        pts = "<b> Points </b>",
        reb = "<b> Rebounds </b>",
        ast = "<b> Assists </b>",
        fg_pct = "<b> FG % </b>",
        fg3_pct = "<b> 3PT % </b>",
        ft_pct = "<b> FT % </b>",
        fga = "FG Attempts",
        fgm = "FG Makes",
        fg3a = "3PT Attempts",
        fg3m = "3PT Makes",
        fta = "FT Attempts",
        ftm = "FT Makes",
        stl = "Steals",
        blk = "Blocks",
        tov = "<b> Turnovers </b>",
        oreb = "Off Rebounds",
        dreb = "Def Rebounds"
  )
  
}

position_mapper <- function(position_vec) { 

  case_when(
        position_vec == "C-F" ~ "C",
        position_vec == "G-F" ~ "G",
        position_vec == "F-G" ~ "F",
        position_vec == "F-C" ~ "F",
        TRUE ~ position_vec
  )

}