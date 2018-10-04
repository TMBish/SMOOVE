get_gcp_rds <- function(object_string) {
    
    # Write locally
    gcs_get_object(
        object_name = object_string,
        bucket = "smoove",
        saveToDisk = "data/temp.rds",
        overwrite = TRUE
    )
  
  # Read
  df = read_rds("data/temp.rds")
  
  # Remove local
  file.remove("data/temp.rds")
  
  return(df)
  
}