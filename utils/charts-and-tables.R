# ++++++++++++++++++++++++
# WRAPPERS
# ++++++++++++++++++++++++

build_season_chart = function(
  game_log, 
  team_log, 
  peer_stats,
  stat_name, 
  per_mode
  ) {
  
  # Get config
  config = assemble_config(app_config, stat_name, game_log = game_log) 
  
  # Assemble chart data
  d_f = assemble_intra_season_data(game_log, team_log, config)
  
  # Get peer median
  peer_median = 
    peer_stats %>% 
    select(value = !!(config %>% pluck("stat-config", "col"))) %>% 
    summarise(median = median(value, na.rm = TRUE)) %>%
    pull(median)

  # Produce chart
  chart = make_season_chart(d_f, config, peer_median, per_mode)
  
  return(chart)
}


build_career_chart = function(career_log, peer_stats, stat_name, per_mode) {
  
  # Get config
  config = assemble_config(app_config, stat_name) 
  
  # Assemble chart data
  d_f = assemble_inter_season_data(career_log, config)
  
  # Get peer median
  peer_median = 
    peer_stats %>% 
    select(value = !!(config %>% pluck("stat-config", "col"))) %>% 
    summarise(median = median(value, na.rm = TRUE)) %>%
    pull(median)
  
  # Produce chart
  chart = make_career_chart(d_f, config, peer_median, per_mode)
  
  return(chart)
  
}


build_distribution_chart = function(player_id, peer_stats, stat_name, per_mode) {
  
  # Get config
  config = assemble_config(app_config, stat_name) 
  
  # Build Chart
  chart = make_distribution_chart(player_id, peer_stats, config, per_mode)
  
}

# ++++++++++++++++++++++++
# CHART BUILDERS
# ++++++++++++++++++++++++

make_distribution_chart = function(plyid, peer_stats, config, per_mode) {
  
  # Stat Label
  stat_label = config %>% pluck("stat-config", "label")

  # Round units
  ru = config %>% pluck("stat-config", "axis", "shift-unit")

  # Square sizing
  players = nrow(peer_stats)
  if (players < 20) {
    square_size = 10
  } else if (players < 40) {
    square_size = 6
  } else if (players < 70) {
    square_size = 4
    ru = ru / 2
  } else {
    square_size = 4
    ru = ru / 4
  }
  
  d_f = 
  peer_stats %>% 
  select(player_name, player_id, "value" = config %>% pluck("stat-config", "col")) %>%
  mutate(
    stat_bucket = round(value / ru) * ru,
    highlight = ifelse(player_id == plyid, "Y", "N")
  ) %>%
  group_by(stat_bucket) %>%
  arrange(value) %>%
  mutate(y = row_number()) %>%
  ungroup() 

  # ++++++++++++
  # Chart Options
  # ++++++++++++

  # Number formatting
  if (str_detect(stat_label, "\\%")) {

    axis_name = stat_label
    axformatter = JS("function(){ return(Math.round(this.value * 100) + '%')}")
    
    # Create tooltip
    d_f = 
      d_f %>%
      mutate(
        tooltip_value = scales::percent(value),
        hctooltip = glue("<b> {player_name} </b> <br> {tooltip_value}")
      )

  } else {

    axis_name = glue("{stat_label} {per_mode}")
    axformatter = JS("function(){ return(this.value) }")

    # Create tooltip
    d_f = 
      d_f %>%
      mutate(
        tooltip_value = value,
        hctooltip = glue("<b> {player_name} </b> <br> {tooltip_value}")
      )

  }

  # ++++++++++++
  # Chart Build
  # ++++++++++++
  hchart(
    d_f %>% filter(highlight == "N"),
    "scatter", 
    hcaes(x = stat_bucket, y = y), 
    marker = list(radius = square_size, symbol = "square"), color = "#e0e0e0"
  ) %>%
  hc_add_series(
    d_f %>% filter(highlight == "Y"),
    "scatter", 
    hcaes(x = stat_bucket, y = y), 
    marker = list(radius = square_size, symbol = "square"), color = "#1d89ff"
  ) %>%
  hc_add_theme(hc_theme_smoove()) %>%
  hc_yAxis(
    title = list(text = ""),
    gridLineWidth = 0,
    lineWidth = 0,
    labels = list(enabled = FALSE)
  ) %>%
  hc_xAxis(
    title = list(text = axis_name),
    labels = list(formatter = axformatter)
  ) %>%
  hc_title(text = "Peer Distribution") %>%
  hc_tooltip(
    useHTML = TRUE,
    formatter = JS("function(){return(this.point.hctooltip)}")
  )
  
  
}


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
  

  # Set a base tooltip formatter for volume stats
  ttformatter = JS("function(){return('<b> Game Number: </b>' + this.x + '<br> <b>' + this.series.name + '</b>: ' + (Math.round(this.y * 100) / 100))}")
  
  # Number formatting
  if (str_detect(stat_label, "\\%")) {
    # A % based stat (per game / per 36 doesn't make sense)
    raw_series_name = stat_label
    y_axis_name = stat_label

    # Need a custom tooltip formatter for this series type
    ttformatter =   
      JS(
            "function(){
              var seriesname = this.series.name;
              if (seriesname.includes('Attempts')) {
                var yval = (Math.round(this.y * 100) / 100);
              } else {
                var yval = Math.round(this.y * 100)  + '%';
              };
              return('<b> Game Number: </b>' + this.x + '<br> <b>' + seriesname + '</b>: ' + yval)
      }")

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
             align = "left"
          )
        #, zIndex = 10
        )
      )
    ) %>%
    hc_xAxis(title = list(text = "Game Number")) %>%
    hc_add_theme(hc_theme_smoove()) %>%
    hc_tooltip(
      formatter = ttformatter,
      crosshairs = TRUE,
      useHTML = TRUE
    )
  
  # Add in volume bar chart if required
  if (volume_required) {
    
    vol_stat_label = 
      config %>% 
      pluck("stat-config", "volume", "stat-label")

    vol_stat_short_label = 
      config %>%
      pluck("stat-config", "volume", "short-label")
    
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
        name = vol_stat_short_label,
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
    
  # ttformatter = JS("function(){
  #   console.log(this);
  #   this.x
  #   }") 

  # Number formatting
  if (str_detect(stat_label, "\\%")) {
    axformatter = JS("function(){ return(Math.round(this.value * 100) + '%')}")
    dlformatter = JS("function(){ return(Math.round(this.y * 100) + '%')}")
    ttformatter = JS(glue("function(){return('<b> Season: </b>' + this.point.name + '<br> <b> <<<stat_label>>></b>: ' + Math.round(this.y * 1000) / 10 + '%')}", .open = "<<<", .close = ">>>"))
    per_mode = ""
  } else {
    axformatter = JS("function(){ return(this.value) }")
    dlformatter = JS("function(){ return(this.y) }")
    ttformatter = JS(glue("function(){return('<b> Season: </b>' + this.point.name + '<br> <b> <<<stat_label>>></b>: ' + this.y )}", .open = "<<<", .close = ">>>")) 
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
          label = list(
            text = "peer median", 
            style = list(color = "#ED074F", fontWeight = "bold", fontSize = "12px"),
            align = "left"
          )
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
          backgroundColor = NULL,
          style = list(textOutline = NULL, fontWeight = "normal", backgroundColor = "#FFF"),
          formatter = dlformatter
        )
      )
    ) %>%
    hc_tooltip(
      useHTML = TRUE,
      formatter = ttformatter,
      crosshairs = TRUE
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

  # If multi team season
  if (d_f %>% summarise(teams = n_distinct(team_id)) %>% pull(teams) > 1) {

    second_team = 
      d_f %>% 
      filter(!is.na(player_id)) %>% 
      # Old team plays new team
      group_by(game_id) %>% mutate(appearances = n()) %>% ungroup() %>%
      filter(appearances == 1) %>%
      # Find earliest game per team
      group_by(team_id) %>% 
      summarise(game_id = min(game_id)) %>% 
      filter(game_id == max(game_id))

    d_f = 
      d_f %>%
      filter(
        (team_id == second_team$team_id & game_id >= second_team$game_id) |
        (team_id != second_team$team_id & game_id < second_team$game_id)
      )
  }
    
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
# TABLES BUILDERS
# ++++++++++++++++++++++++

build_player_table = function(
  plyid, 
  statsdf, 
  playerdf,
  careerstatsdf,
  peer_stats, 
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
  
  # Get poisition per 36 average
  peer_median = 
    peer_stats %>%
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
        estimator = ecdf(peer_stats %>% pull(statistic))
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