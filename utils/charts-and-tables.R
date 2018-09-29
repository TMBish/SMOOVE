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

build_season_chart = function(game_log, team_log, stat_name, per_mode) {
  
  # Get config
  config = assemble_intra_season_config(game_log, app_config, stat_name) 
  
  # Assemble chart data
  d_f = assemble_intra_season_data(game_log, team_log, config)
  
  # Get median
  
  # Produce Chart
  chart = make_season_chart(d_f, config, per_mode)
}

# ++++++++++++++++++++++++
# CHART BUILDERS
# ++++++++++++++++++++++++

make_season_chart = function(chart_input, config, per_mode) {

  # ++++++++++++
  # Chart Options
  # ++++++++++++
  
  stat_label = config %>% pluck("stat_config", "label")
  volume_required = !(config %>% pluck("stat_config", "volume") %>% is.null())
  
  # Number formatting
  if (str_detect(stat_label, "\\%")) {
    per_mode = ""
  }
  
  # ++++++++++++
  # Chart Build
  # ++++++++++++
  chart = 
    highchart() %>%
    hc_add_series(
      name = glue("{stat_name} {ifelse(per_mode=='Per 36', per_mode, '')}"),
      chart_input,
      "scatter",
      hcaes(x = game_number, y = raw), 
      color = "rgba(62, 63, 58, 0.75)"
    ) %>%
    hc_add_series(name = "Rolling Avg", chart_input, "spline", hcaes(x = game_number, y = rolling_average)) %>%
    hc_add_series(name = "Season Avg", chart_input, "spline", visible= FALSE, hcaes(x = game_number, y = season_average)) %>%
    hc_title(text = config %>% pluck("season_name")) %>%
    hc_yAxis(
      title = list(text = glue("{stat_label} {per_mode}")),
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
  if (volume_required) {
    
    vol_stat_label = config %>% pluck("stat_config", "volume", "stat-label")
    
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
  
  
  
  
}

# ++++++++++++++++++++++++
# CHART DATA BUILDERS
# ++++++++++++++++++++++++

assemble_intra_season_config = function(gamelog, app_config, stat_name) {
  
  output = list()
  
  output$season_name = gamelog$season[1]  
  output$stat_config = app_config %>% pluck("basic-stats", stat_name)
  output$stat_config$label = stat_name
  
  return(output)
  
}

assemble_intra_season_data = function(gamelog, teamlog, config) {
  
  # Get info from the config list
  col = config %>% pluck("stat_config", "col")
  vol_switch = config %>% pluck("stat_config", "volume") %>% is.null()
  
  # Join player gamelog and teamlog
  d_f = 
    teamlog %>%
    left_join(gamelog, by = "game_id") %>%
    arrange(game_id) %>%
    mutate(game_number = row_number())
    
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
      rolling_average== 0 | is.nan(rolling_average) | is.na(raw) ~ NA_real_,
      TRUE ~ rolling_average
    )
  )
  
}

# ++++++++++++++++++++++++
# CHART BUILDERS
# ++++++++++++++++++++++++




assemble_inter_season_data = function() {
  
  
  
}

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