reponse_to_df <- function(response, index = 1) {
  
  # Manipulate Response Object
  results = response %>%
    pluck("content") %>%
    rawToChar() %>%
    fromJSON() %>%
    pluck("resultSets")
  
  if (results %>% pluck("rowSet") %>% length() < index) {
    stop(glue("Response includes less than {index} items"))
  }
  
  # Get the data
  df = results %>%
    pluck("rowSet") %>% 
    pluck(index) %>%
    as_tibble()
  
  # Get the columns  
  colnames = results %>%
    pluck("headers") %>% 
    pluck(index) %>%
    tolower()
  
  # Add Col Names
  df = setNames(df, colnames)
  
  # Auto Detect Data Types
  df = df %>% type_convert()
  
  return(df)
  
}