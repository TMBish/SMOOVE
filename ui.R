shinyUI(
  
  fluidPage(
    
    # Shiny Dashboard CSS
    tags$head(
      includeCSS(file.path('www', path = "AdminLTE.css")),
      includeCSS(file.path('www', path = "shinydashboard.css")),
      includeCSS(file.path('www', path = "style.css"))
    ),
    
    
    #source("./ui/nav-bar.R", local=TRUE)$value,
  
    fluidRow(class = 'center-children',
      
        column(3,
          h1("NBA PocketBook")
        )
        
    ),     
    
    fluidRow(class = "main-page",
             
              column(4,

                     source("./ui/side-bar.R", local=TRUE)$value

             ),

             column(8, class="page-pane",
                    
                    #source("./ui/top-row.R", local=TRUE)$value,
                    
                    source("./ui/body.R", local=TRUE)$value
                    
             )
             # 
             # column(2, class = "right-bar",
             #        
             #        shiny::img(
             #          src = "nba_pocketbook_logo.png", 
             #          local = T
             #        ),
             #        wellPanel()
             #        )
             # 
             
             
    )
    
    
  )
)











