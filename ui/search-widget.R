
div(class = "sidebar",       
  # Logo
  shiny::img(
    src = "nba_pocketbook_logo.png", 
    local = T
  ),

  # Player Search
  searchInput(
    inputId = "player", 
    label = "Enter a player name:", 
    placeholder = "Lebron James", 
    btnSearch = icon("search"), 
    btnReset = icon("remove"), 
    width = "100%"
  )
)