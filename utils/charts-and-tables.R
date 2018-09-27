# ++++++++++++++++++++++++
# WRAPPERS
# ++++++++++++++++++++++++

build_season_charts = function(gl) {
  
  # Iterators
  stat_set = app_config$`basic-stats` %>% names()
  stat_set = stat_set[stat_set!="Minutes"]

  # Build
  stat_set %>%
    map(chart_stat_season, gamelog = gl) %>%
    setNames(stat_set) %>%
    return()
  
}


build_career_charts = function(cr) {
  
  # Iterators
  stat_set = app_config$`basic-stats` %>% names()
  stat_set = stat_set[stat_set!="Minutes"]
  
  # Build
  stat_set %>%
    map(chart_stat_career, career_stats = cr) %>%
    setNames(stat_set) %>%
    return()
  
}

# ++++++++++++++++++++++++
# CHART BUILDERS
# ++++++++++++++++++++++++
chart_stat_season = function(gamelog, stat_name, window = 5) {
  
  # Season Name
  seaon_name = gamelog$season[1]
  
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
    hc_add_series(name = glue("{stat_name}"), df, "scatter", hcaes(x = game_number, y = raw)) %>%
    hc_add_series(name = "Rolling Avg", df, "spline", hcaes(x = game_number, y = rolling_average)) %>%
    hc_add_series(name = "Season Avg", df, "spline", visible= FALSE, hcaes(x = game_number, y = season_average)) %>%
    hc_title(text = seaon_name) %>%
    hc_yAxis(title = list(text = stat_name)) %>%
    hc_xAxis(title = list(text = "Game Number")) %>%
    hc_add_theme(hc_theme_smoove()) %>%
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


chart_stat_career = function(career_stats, stat_name, window = 3) {
  
  # Get field config from app config list in parent environment
  conf_item = app_config %>% pluck("basic-stats", stat_name)
  
  # Get real col header name from config
  col = conf_item %>% pluck("col")
  
  # Boolean to control whether to chart volume (attempts) as bar chart
  vol_switch = conf_item %>% pluck("volume-stat") %>% is.null()
  
  # Season ID Map
  career_stats = career_stats %>% mutate(season_id = str_sub(season_id, start = 3))
  
  # Based on boolean select the stat col and maybe volume col
  if (vol_switch) {
    df = career_stats %>% select(season_id, season_avg = !!col) 
  } else {
    vol_col = conf_item %>% pluck("volume-stat") 
    df = career_stats %>% select(season_id, season_avg = !!col, volume = !!vol_col) 
  }
  
  # Add in game number and cumulative season average
  df = df %>% arrange(season_id)
  
  # Formatter
  if (str_detect(stat_name, "\\%")) {
    formatter = JS("function(){ return(Math.round(this.y * 100) + '%')}")
  } else {
    formatter = JS("function(){ return(this.y) }")
  }
  
  
  # Create Basic Chart
  chart = 
    hchart(df, name = "Season Avg", "column", hcaes(x = season_id, y = season_avg)) %>%
    hc_title(text = "Career") %>%
    hc_colors("#1d89ff") %>%
    hc_yAxis(title = list(text = stat_name)) %>%
    hc_xAxis(title = list(text = "Season"), labels = list(formatter = formatter)) %>%
    hc_add_theme(hc_theme_smoove()) %>%
    hc_plotOptions(
      column = list(
        dataLabels = list(
          enabled = TRUE,
          #inside = TRUE,
          #verticalAlign = "top",
          #color = "#FFF",
          backgroundColor = NULL,
          style = list(textOutline = NULL,
                       #fontSize = "6px", 
                       fontWeight = "bold"),
          formatter = formatter
        )
      )
    )
  
  
  return(chart)
  
  
}

# ++++++++++++++++++++++++
# TABLES BUILDERS
# ++++++++++++++++++++++++

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