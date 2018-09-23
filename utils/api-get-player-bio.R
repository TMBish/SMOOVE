get_player_info = function(player_id) {
  
  # Params
  endpoint = 'commonplayerinfo'

  # Assemble Params
  params = list(
    'PlayerID' = player_id
  )
  
  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = reponse_to_df(response, 1)
  
  return(df)
  
}