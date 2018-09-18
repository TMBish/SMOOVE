get_team_roster = function(team_id) {
  
  # Params
  endpoint = 'commonteamroster'

  # Assemble Params
  params = list(
    'Season' = "2017-18",
    'TeamID' = team_id
  )

  # Submit Request
  response = submit_request(endpoint, params)
  
  # Convert first element of response to DF
  df = reponse_to_df(response, 1)
  
  return(df)
  
}