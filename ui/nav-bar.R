div(class='nav-bar',

      h1(app_title),
      
      # Player Search
      searchInput(
        inputId = "player_", 
        label = "Enter a player name:", 
        placeholder = "Lebron James", 
        btnSearch = icon("search"), 
        btnReset = icon("remove")
        #, width = "100%"
      )

)