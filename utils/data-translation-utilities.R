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