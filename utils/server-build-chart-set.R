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

