get_current_season = function() {
  
  current_date = Sys.Date()
  current_year = lubridate::year(current_date)-1 ### CHANGE THISSSSS
  
  if (lubridate::month(current_date) > 6) {
    dte_string = paste0(current_year, "-", (current_year + 1)-2000)
  } else {
    dte_string = paste0(current_year - 1, "-", current_year-2000)
  }
  
  return(dte_string)
}