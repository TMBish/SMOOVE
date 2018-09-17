build_chart_set = function(gamelog) {
	
	# Iterators
	stat_set = app_config$`basic-stats` %>% names()
	stat_set = stat_set[stat_set!="Minutes"]

	# Build
	stat_set %>%
		map(chart_rolling_mean, gamelog=gamelog) %>%
		setNames(stat_set) %>%
		return()
	
}