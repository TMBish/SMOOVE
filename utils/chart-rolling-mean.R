chart_rolling_mean = function(gamelog, stat_name, window = 5) {
  
  # Get field config from app config list in parent environment
  conf_item = app_config %>% pluck("basic-stats", stat_name)
  
  # Get real col header name from config
  col = conf_item %>% pluck("col")
  
  # Boolean to control whether to chart volume (attempts) as bar chart
  vol_switch = conf_item %>% pluck("volume-stat") %>% is.null()
  
  # Based on boolean select the stat col and maybe volume col
  if (vol_switch) {
    df = gamelog %>% select(raw = !!col) 
  } else {
    vol_col = conf_item %>% pluck("volume-stat") 
    df = gamelog %>% select(raw = !!col, volume = !!vol_col) 
  }

  # Add in game number and cumulative season average
  df = df %>%
    mutate(
      game_number = row_number(),
      season_average = cummean(raw)
    )

  # Add right aligned moving average based on window criteria
  df$rolling_average = rollmean(df$raw, k = window, fill = NA, align = 'right')
    
  # Create Basic Chart
  chart = hchart(name = glue("Raw {stat_name}"), df, "scatter", hcaes(x = game_number, y = raw)) %>%
    hc_add_series(name = "Rolling Average", df, "spline", hcaes(x = game_number, y = rolling_average)) %>%
    hc_add_series(name = "Season Average", df, "spline", hcaes(x = game_number, y = season_average)) %>%
    hc_title(text = stat_name) %>%
    hc_subtitle(text = glue("With rolling {window} game average and cumulative season average")) %>%
    hc_yAxis(title = list(text = stat_name)) %>%
    hc_xAxis(title = list(text = "Game Number")) %>%
    hc_add_theme(hc_theme_nba())
  
  # Add in volume bar chart if required
  if (!vol_switch) {
    
    vol_stat_label = conf_item %>% pluck("volume-stat-label")
    
    chart = chart %>%
      hc_yAxis_multiples(
        list(),
        list(title = list(text = vol_stat_label), opposite = TRUE)
      ) %>%
      hc_add_series(
        name = vol_stat_label,
        df,
        "column",
        hcaes(x = game_number, y = volume),
        yAxis = 1,
        zIndex = -10
      )
    
  }
  
  return(chart)
  
  
}