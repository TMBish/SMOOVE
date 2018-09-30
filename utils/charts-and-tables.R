# ++++++++++++++++++++++++
# WRAPPERS
# ++++++++++++++++++++++++

build_season_chart = function(game_log, team_log, season_stat_master, stat_name, per_mode) {
  
  # Examples
  # plyrid = get_player("Justise", "Winslow")
  # game_log = get_player_gamelog(plyrid, season = "2017-18")
  # career_log = get_player_career_stats(plyrid)
  # stat_name = "Field Goal %"
  # team_log = get_team_games(player_master %>% filter(player_id == plyrid) %>% pull(teamid))
  # season_stat_master = stats_master
  
  # Get config
  config = assemble_config(app_config, stat_name, game_log = game_log) 
  
  # Assemble chart data
  d_f = assemble_intra_season_data(game_log, team_log, config)
  
  # Get peer median
  peer_median = get_peer_median(season_stat_master, config %>% pluck("stat-config", "label"))

  # Produce chart
  chart = make_season_chart(d_f, config, peer_median, per_mode)
  
  return(chart)
}


build_career_chart = function(career_log, season_stat_master, stat_name, per_mode) {
  
  # Get config
  config = assemble_config(app_config, stat_name) 
  
  # Assemble chart data
  d_f = assemble_inter_season_data(career_log, config)
  
  # Get peer median
  peer_median = get_peer_median(season_stat_master, config %>% pluck("stat-config", "label"))
  
  # Produce chart
  chart = make_career_chart(d_f, config, peer_median, per_mode)
  
  return(chart)
}

# ++++++++++++++++++++++++
# CHART BUILDERS
# ++++++++++++++++++++++++

make_season_chart = function(chart_input, config, peer_median, per_mode) {

  # ++++++++++++
  # Chart Options
  # ++++++++++++
  
  # English name of the stat for labels
  stat_label = 
    config %>% 
    pluck("stat-config", "label")
    
  # Is it a volume based stat to plot the volume bars
  volume_required = 
    !(
      config %>% 
      pluck("stat-config", "volume") %>% 
      is.null()
    )
  
  # Number formatting
  if (str_detect(stat_label, "\\%")) {
    # A % based stat (per game / per 36 doesn't make sense)
    raw_series_name = stat_label
    y_axis_name = stat_label
  } else if (per_mode == "Per 36") {
    # Per 36 & Not a % based stat
    raw_series_name = glue("{stat_label} {per_mode}")
    y_axis_name = glue("{stat_label} {per_mode}")
  } else {
    # Per Game & Not a % based stat
    raw_series_name = stat_label
    y_axis_name = glue("{stat_label} {per_mode}")
  }
  
  # ++++++++++++
  # Chart Build
  # ++++++++++++
  
  chart = 
    highchart() %>%
    hc_add_series(
      name = raw_series_name,
      chart_input,
      "scatter",
      hcaes(x = game_number, y = raw), 
      color = "rgba(62, 63, 58, 0.75)"
    ) %>%
    hc_add_series(name = "Rolling Avg", chart_input, "spline", hcaes(x = game_number, y = rolling_average)) %>%
    hc_add_series(name = "Season Avg", chart_input, "spline", visible= FALSE, hcaes(x = game_number, y = season_average)) %>%
    hc_title(text = config %>% pluck("season_name")) %>%
    hc_yAxis(
      title = list(text = glue("{stat_label}")),
      plotLines = list(
        list(
          value = peer_median,
          color = "#ED074F",
          width = 1,
          label = list(
            text = "peer median",
             style = list(color = "#ED074F", fontWeight = "bold", fontSize = "12px"),
             align = "right"
          )
        #, zIndex = 10
        )
      )
    ) %>%
    hc_xAxis(title = list(text = "Game Number")) %>%
    hc_add_theme(hc_theme_smoove()) %>%
    hc_tooltip(shared = TRUE, crosshairs = TRUE)
  
  # Add in volume bar chart if required
  if (volume_required) {
    
    vol_stat_label = 
      config %>% 
      pluck("stat-config", "volume", "stat-label")
    
    chart = chart %>%
      hc_yAxis_multiples(
        list(
          labels = list(formatter = JS("function(){return(this.value*100 + '%')}")), 
          title = list(text = raw_series_name),
          plotLines = list(
            list(
              value = peer_median,
              color = "#ED074F",
              width = 1,
              label = list(
                text = "peer median",
                 style = list(color = "#ED074F", fontWeight = "bold", fontSize = "12px"),
                 align = "left"
              )
            , zIndex = 10
            )
          )
        ),
        list(title = list(text = vol_stat_label), opposite = TRUE)
      ) %>%
      hc_add_series(
        name = vol_stat_label,
        chart_input,
        "column",
        hcaes(x = game_number, y = volume),
        yAxis = 1,
        zIndex = -10,
        color = "#E0E0E0"
      )
    
  }
  
  return(chart)
  
}


make_career_chart = function(chart_input, config, peer_median, per_mode) {
  
  # ++++++++++++
  # Chart Options
  # ++++++++++++
  
  # English name of the stat for labels
  stat_label = 
    config %>% 
    pluck("stat-config", "label")
    
  # Number formatting
  if (str_detect(stat_label, "\\%")) {
    axformatter = JS("function(){ return(Math.round(this.value * 100) + '%')}")
    dlformatter = JS("function(){ return(Math.round(this.y * 100) + '%')}")
    per_mode = ""
  } else {
    axformatter = JS("function(){ return(this.value) }")
    dlformatter = JS("function(){ return(this.y) }")
  }
  
  # Axis Limits
  y_min = pmin(
    # Default Min
    config %>% pluck("stat-config", "axis", "default-min"), 
    # Player Specific
    (chart_input %>% pull(season_avg) %>% min()) - config %>% pluck("stat-config", "axis", "shift-unit")
  )
  y_max = pmax(
    # Default Min
    config %>% pluck("stat-config", "axis", "default-max"), 
    # Player Specific
    (chart_input %>% pull(season_avg) %>% max()) + config %>% pluck("stat-config", "axis", "shift-unit")
  )
  
  # ++++++++++++
  # Chart Build
  # ++++++++++++
  chart = 
    hchart(
      chart_input, 
      name = "Season Avg", 
      "column", 
      hcaes(x = season_id, y = season_avg)
    ) %>%
    hc_title(text = "Career") %>%
    hc_colors("#1d89ff") %>%
    hc_yAxis(
      title = list(text = glue("{stat_label} {per_mode}")), 
      labels = list(formatter = axformatter),
      min = y_min, max = y_max,
      plotLines = list(
        list(
          value = peer_median,
          color = "#ED074F",
          width = 1,
          label = list(text = "peer median", style = list(color = "#ED074F", fontWeight = "bold", fontSize = "12px"))
          #, zIndex = 10
        )
      )
    ) %>%
    hc_xAxis(title = list(text = "Season")) %>%
    hc_add_theme(hc_theme_smoove()) %>%
    hc_plotOptions(
      column = list(
        dataLabels = list(
          enabled = TRUE,
          #inside = TRUE,
          #verticalAlign = "top",
          #color = "#FFF",
          backgroundColor = NULL,
          style = list(textOutline = NULL, fontWeight = "normal", backgroundColor = "#FFF"),
          formatter = dlformatter
        )
      )
    )
    
    
    return(chart)
  
  
}

# ++++++++++++++++++++++++
# CHART DATA BUILDERS
# ++++++++++++++++++++++++

assemble_config = function(app_config, stat_name, game_log = NULL) {
  
  output = list()
  
  # Stat information
  output$`stat-config` = app_config %>% pluck("basic-stats", stat_name)
  output$`stat-config`$label = stat_name
  
  # Season if gamelog provided
  if (!is.null(game_log)) output$season_name = game_log$season[1]
  
  return(output)
  
}

assemble_intra_season_data = function(game_log, team_log, config) {
  
  # Get info from the config list
  col = config %>% pluck("stat-config", "col")
  vol_switch = config %>% pluck("stat-config", "volume") %>% is.null()
  
  # Join player gamelog and teamlog
  d_f = 
    team_log %>%
    left_join(game_log, by = "game_id") 
    # %>% arrange(game_id) %>%
    # mutate(game_number = row_number())
    
  # Based on boolean select the stat col and maybe volume col
  if (vol_switch) {
    
    # No volume base info needed
    d_f =  
      d_f %>% 
      select(game_number, raw = !!col) %>%
      mutate_at(vars(raw), as.numeric) %>%
      mutate(
        rolling_average = 
          rollsum(coalesce(raw, 0), k = 5, fill = NA, align = 'right') / 
          rollsum(!is.na(raw), k = 5, fill = NA, align = 'right'),
        season_average = cumsum(coalesce(raw, 0)) / cumsum(!is.na(raw))
      ) %>%
      select(game_number, raw, rolling_average, season_average)
      
  } else {
    
    # Need to include volume and stuff
    vol_attempts = config %>% pluck("stat-config", "volume", "attempts") 
    vol_makes = config %>% pluck("stat-config", "volume", "makes")
    
    d_f =  
      d_f %>% 
      select(game_number, 
        raw = !!col, attempts = !!vol_attempts, makes = !!vol_makes
      ) %>%
      mutate_at(vars(raw, makes, attempts), as.numeric) %>%
      mutate(
        cum_makes = cumsum(coalesce(makes, 0)),
        cum_attempts = cumsum(coalesce(attempts, 0))
      ) %>%
      mutate(
        season_average = cum_makes / cum_attempts,
        rolling_average = 
          rollsum(coalesce(makes, 0), k = 5, fill = NA, align = 'right') / 
          rollsum(coalesce(attempts, 0), k = 5, fill = NA, align = 'right')
      ) %>%
      select(game_number, raw, rolling_average, season_average, "volume" = attempts)
  }
  
  d_f %>%
  mutate(
    rolling_average = case_when(
      rolling_average== 0 | is.nan(rolling_average) | is.na(raw) | (rollsum(!is.na(raw),k = 5, fill = NA, align = 'right') <= 2) ~ NA_real_,
      TRUE ~ rolling_average
    )
  )
  
}

assemble_inter_season_data = function(career_log, config) {

  # Get info from the config list
  col = config %>% pluck("stat-config", "col")
  vol_switch = config %>% pluck("stat-config", "volume") %>% is.null()
  
  # Season ID Map
  career_log = 
    career_log %>% 
    arrange(season_id) %>%
    mutate(season_id = str_sub(season_id, start = 3))
  
  # Based on boolean select the stat col and maybe volume col
  if (vol_switch) {
    d_f = career_log %>% select(season_id, season_avg = !!col) 
  } else {
    vol_col = config %>% pluck("stat-config", "volume", "attempts") 
    d_f = career_log %>% select(season_id, season_avg = !!col, volume = !!vol_col) 
  }
  
  return(d_f)
  
}

# ++++++++++++++++++++++++
# CHART BUILDERS
# ++++++++++++++++++++++++


chart_stat_season = function(gamelog, stat_name, stat_median, per_mode, window = 5) {
  
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
  
  # ++++++++++++
  # Chart Options
  # ++++++++++++
  
  # Number formatting
  if (str_detect(stat_name, "\\%")) {
    per_mode = ""
  }
  
  # ++++++++++++
  # Chart Build
  # ++++++++++++
  chart = 
    highchart() %>%
    hc_add_series(name = glue("{stat_name} {ifelse(per_mode=='Per 36', per_mode, '')}"), df, "scatter", hcaes(x = game_number, y = raw), color = "rgba(62, 63, 58, 0.75)") %>%
    hc_add_series(name = "Rolling Avg", df, "spline", hcaes(x = game_number, y = rolling_average)) %>%
    hc_add_series(name = "Season Avg", df, "spline", visible= FALSE, hcaes(x = game_number, y = season_average)) %>%
    hc_title(text = seaon_name) %>%
    hc_yAxis(
      title = list(text = glue("{stat_name} {per_mode}")),
      plotLines = list(
        list(
          value = stat_median,
          color = "#ED074F",
          width = 1,
          label = list(
            text = "peer median",
             style = list(color = "#ED074F", fontWeight = "bold", fontSize = "12px"),
             align = "right"
          )
        #, zIndex = 10
        )
      )
    ) %>%
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


chart_stat_career = function(career_stats, stat_name, per_mode, stat_median) {
  
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
  
  # ++++++++++++
  # Chart Options
  # ++++++++++++
  
  # Number formatting
  if (str_detect(stat_name, "\\%")) {
    axformatter = JS("function(){ return(Math.round(this.value * 100) + '%')}")
    dlformatter = JS("function(){ return(Math.round(this.y * 100) + '%')}")
    per_mode = ""
  } else {
    axformatter = JS("function(){ return(this.value) }")
    dlformatter = JS("function(){ return(this.y) }")
  }
  
  # Axis Limits
  y_min = pmin(
    # Default Min
    conf_item %>% pluck("axis", "default-min"), 
    # Player Specific
    (df %>% pull(season_avg) %>% min()) - conf_item %>% pluck("axis", "shift-unit")
  )
  y_max = pmax(
    # Default Min
    conf_item %>% pluck("axis", "default-max"), 
    # Player Specific
    (df %>% pull(season_avg) %>% max()) + conf_item %>% pluck("axis", "shift-unit")
  )
  
  # ++++++++++++
  # Chart Build
  # ++++++++++++
  chart = 
    hchart(
      df, 
      name = "Season Avg", 
      "column", 
      hcaes(x = season_id, y = season_avg)
    ) %>%
    hc_title(text = "Career") %>%
    hc_colors("#1d89ff") %>%
    hc_yAxis(
      title = list(text = glue("{stat_name} {per_mode}")), 
      labels = list(formatter = axformatter),
      min = y_min, max = y_max,
      plotLines = list(list(
        value = stat_median,
        color = "#ED074F",
        width = 1,
        label = list(text = "peer median", style = list(color = "#ED074F", fontWeight = "bold", fontSize = "12px"))
        #, zIndex = 10
      ))
    ) %>%
    hc_xAxis(title = list(text = "Season")) %>%
    hc_add_theme(hc_theme_smoove()) %>%
    hc_plotOptions(
      column = list(
        dataLabels = list(
          enabled = TRUE,
          #inside = TRUE,
          #verticalAlign = "top",
          #color = "#FFF",
          backgroundColor = NULL,
          style = list(textOutline = NULL, fontWeight = "normal", backgroundColor = "#FFF"),
          formatter = dlformatter
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
  careerstatsdf, 
  starter_bench,
  position,
  per36 = FALSE
) {
  
  # Per36 Switch
  if (per36) {
    statsdf = allplayerstats_to_perM(statsdf)
  }

  # Career Averages
  career_avgs = get_career_average(careerstatsdf, per36 = per36)

  # Join player and stats data
  statsdf = 
    statsdf %>%
    inner_join(playerdf %>% select(player_id, position)) %>%
    mutate(position_map = position_mapper(position)) 
  
  # Stats of interest
  statcats = c(
    "min", "pts", "reb", "ast", 
    "fg_pct", "fg3_pct","ft_pct", 
     "stl", "blk", "tov",
    "fga","fg3a", "fta", "oreb", "dreb"
  )
  
  this_season = 
    statsdf %>% 
    filter(player_id == plyid) %>%
    mutate(min = ifelse(per36, 36, min)) %>%
    select(one_of(statcats))
    
  player_table = 
    this_season %>%
    mutate_at(vars(contains("pct")), scales::percent) %>%
    gather(statistic, this_season) %>%
    inner_join(
      career_avgs %>%
        mutate_at(vars(contains("pct")), scales::percent) %>%
        gather(statistic, career_avg)
    )
  
  # +++++++++++++
  # Peer Data
  # +++++++++++++
  
  if (starter_bench == "Starting") {
    peer_base = 
      statsdf %>%
      filter(min > 28 & gp > 5) %>%
      filter(position_map == position) %>%
      select(one_of(statcats))
  } else {
    peer_base = 
      statsdf %>%
      filter(min < 28 & gp > 5) %>%
      filter(position_map == position) %>%
      select(one_of(statcats))
  }
  
  # Get poisition per 36 average
  peer_median = 
    peer_base %>%
    summarise_all(median) %>%
    mutate_at(vars(contains("pct")), scales::percent) %>%
    mutate(min = ifelse(per36, 36, min)) %>%
    gather(statistic, peer_median)
  
  # Peer percentile
  peer_percentile = 
    this_season %>%
    gather(statistic, value) %>%
    pmap_dfr(
      .f = function(statistic, value) {
        estimator = ecdf(peer_base %>% pull(statistic))
        tibble(
          statistic = statistic,
          peer_percentile = round(estimator(value) * 100, 0)
        )
      }
    )
    
  # +++++++++++++
  # Assemble
  # +++++++++++++
  player_table %>%
    inner_join(peer_median, by = "statistic") %>%
    inner_join(peer_percentile, by = "statistic") %>%
    select(statistic, career_avg, this_season, peer_median, peer_percentile) %>%
    mutate(statistic = data_stat_translation(statistic)) %>%
    return()
  
}