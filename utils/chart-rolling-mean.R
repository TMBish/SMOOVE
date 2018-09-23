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
    hc_title(text = "Intra Season") %>%
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