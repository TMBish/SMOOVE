build_player_table = function(
  plyid, 
  statsdf, 
  playerdf,
  # careerstatsdf, 
  per36 = FALSE
) {
  
  # Per36 Switch
  # if (per36) {
  #   statsdf = allplayerstats_to_perM(statsdf)
  #   careerstatsdf = 
  # }

  # Join player and stats data
  statsdf = 
    statsdf %>%
    inner_join(playerdf %>% select(player_id, position)) %>%
    mutate(position_map = case_when(
      position == "C-F" ~ "C",
      position == "G-F" ~ "G",
      position == "F-G" ~ "F",
      position == "F-C" ~ "F",
      TRUE ~ position
    )) %>%
    mutate(total_mins = gp * min) 
  
  # Player position
  plyr_pos = statsdf %>% filter(player_id == plyid) %>% pull(position_map)
  
  # Stats of interest
  statcats = c(
    "min", "pts", "reb", "ast", 
    "fg_pct", "fg3_pct","ft_pct", 
     "stl", "blk", "tov",
    "fga","fg3a", "fta", "oreb", "dreb"
  )
  
  per_game = 
    statsdf %>% 
    filter(player_id == plyid) %>%
    select(one_of(statcats))
    
  per36_multiplier = 36 / per_game$min
    
  per36 = 
    per_game %>%
    mutate_at(vars(-min, -fg_pct, -fg3_pct, -ft_pct), function(x){round(x * per36_multiplier,1)})
  
  player_table = 
    per_game %>%
    mutate_at(vars(contains("pct")), scales::percent) %>%
    gather(statistic, per_game) %>%
    inner_join(
      per36 %>%
        mutate_at(vars(contains("pct")), scales::percent) %>%
        mutate(min = "-") %>%
        gather(statistic, per_36)
    )
    
  # Get poisition per 36 average
  position_per36_median = 
    statsdf %>%
    filter(total_mins > 250) %>%
    filter(position_map == plyr_pos) %>%
    select(player_id, one_of(statcats)) %>%
    gather(variable, value, -player_id, -min) %>%
    mutate(per_36 = case_when(
      variable %>% str_detect("pct") ~ value,
      TRUE ~ round(value * (36 / min),1)
    )) %>%
    select(-value) %>%
    spread(variable, per_36) %>%
    select(-player_id) %>%
    summarise_all(median) %>%
    mutate_at(vars(contains("pct")), scales::percent) %>%
    mutate(min = "-") %>%
    gather(statistic, position_per36_median)
  
  player_table %>%
    inner_join(position_per36_median) %>%
    mutate(
      statistic = recode(statistic,
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
    ) %>%
    return()
  
}