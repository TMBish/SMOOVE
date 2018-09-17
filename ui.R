shinyUI(
  
  fluidPage(
    
    # Shiny Dashboard CSS
    tags$head(
      includeCSS(file.path('www', path = "AdminLTE.css")),
      includeCSS(file.path('www', path = "shinydashboard.css")),
      includeCSS(file.path('www', path = "style.css"))
    ),
    
    
    #source("./ui/nav-bar.R", local=TRUE)$value,
  
    fluidRow(
      
        column(3, 
          h1("NBA pocketbook.")
        ),
        
        column(4, 
        # Player Search
        searchInput(
          inputId = "player", 
          label = "Enter a player name:", 
          placeholder = "Lebron James", 
          btnSearch = icon("search"), 
          btnReset = icon("remove")
          #, width = "100%"
        )
        )
    ),     
    
    fluidRow(class = "main-page",
             
             # column(2, class="page-pane centered",
                    
             #        #source("./ui/search-widget.R", local=TRUE)$value
                    
             # ),
             
             column(10, class="page-pane",
                    
                    #source("./ui/top-row.R", local=TRUE)$value,
                    
                    source("./ui/body.R", local=TRUE)$value
                    
             ),
             
             column(2, class = "right-bar",
                    
                    shiny::img(
                      src = "nba_pocketbook_logo.png", 
                      local = T
                    ),
                    wellPanel()
                    )
             
             
             
    )
    
    
  )
)











