chart_rolling_mean = function(gamelog, stat_name, window = 5) {
  
  # Get field config from app config list in parent environment
  conf_item = app_config %>% pluck("basic-stats", stat_name)
  
  # Get real col header name from config
  col = conf_item %>% pluck("col")
  
  # Boolean to control whether to chart volume (attempts) as bar chart
  vol_switch = conf_item %>% pluck("volume-stat") %>% is.null()
  
  # Based on boolean select the stat col and maybe volume col
  if (vol_switch) {
    df = gamelog %>% select(game_id, raw = !!col) 
  } else {
    vol_col = conf_item %>% pluck("volume-stat") 
    df = gamelog %>% select(game_id, raw = !!col, volume = !!vol_col) 
  }

  # Add in game number and cumulative season average
  df = df %>%
    arrange(game_id) %>%
    select(-game_id) %>%
    mutate(
      game_number = row_number(),
      season_average = cummean(raw)
    )

  # Add right aligned moving average based on window criteria
  df$rolling_average = rollmean(df$raw, k = window, fill = NA, align = 'right')
    
  # Create Basic Chart
  chart = 
    highchart() %>%
    #hchart(name = glue("Raw {stat_name}"), df, "scatter", hcaes(x = game_number, y = raw)) %>%
    hc_add_series(name = glue("Raw {stat_name}"), df, "scatter", hcaes(x = game_number, y = raw)) %>%
    hc_add_series(name = "Rolling Average", df, "spline", hcaes(x = game_number, y = rolling_average)) %>%
    hc_add_series(name = "Season Average", df, "spline", visible= FALSE, hcaes(x = game_number, y = season_average)) %>%
    hc_title(text = stat_name) %>%
    #hc_subtitle(text = glue("With rolling {window} game average and cumulative season average")) %>%
    hc_yAxis(title = list(text = stat_name)) %>%
    hc_xAxis(title = list(text = "Game Number")) %>%
    hc_add_theme(hc_theme_nba()) %>%
    hc_tooltip(shared = TRUE, crosshairs = TRUE)
  
  # Add in volume bar chart if required
  if (!vol_switch) {
    
    vol_stat_label = conf_item %>% pluck("volume-stat-label")
    
    chart = chart %>%
      hc_yAxis_multiples(
        list(labels = list(formatter = JS("function(){return(this.value*100 + '%')}")), title = list(text = stat_name)),
        list(title = list(text = vol_stat_label), opposite = TRUE)
      ) %>%
      hc_add_series(
        name = vol_stat_label,
        df,
        "column",
        hcaes(x = game_number, y = volume),
        yAxis = 1,
        zIndex = -10,
        color = "#E0E0E0"
      )
    
  }
  
  return(chart)
  
  
}


build_player_table = function(plyid, statsdf, playerdf) {
  
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