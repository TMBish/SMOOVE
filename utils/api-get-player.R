get_player = function(first_name, last_name, id_only = TRUE) {
  
  first_name = first_name %>% str_trim() %>% str_to_lower()
  last_name = last_name %>% str_trim() %>% str_to_lower()
  
  # Get All Players
  players = get_all_players(only_current_plyrs = 0)
  
  # Filter
  plyr = players %>%
    filter(str_to_lower(display_first_last) == paste(first_name, last_name))
  
  if (id_only) {
    
    return(plyr %>% pull(person_id))
    
  } else {
    
    return(plyr)
    
  }
  
}