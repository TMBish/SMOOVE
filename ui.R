shinyUI(
  
  fluidPage(
    
    # Shiny Dashboard CSS
    tags$head(
      includeCSS(file.path('www', path = "AdminLTE.css")),
      includeCSS(file.path('www', path = "shinydashboard.css")),
      includeCSS(file.path('www', path = "style.css"))
    ),
    
    
    #source("./ui/nav-bar.R", local=TRUE)$value,
  
    fluidRow(class = 'center-children title-bar',
      
        column(3,
          h1("SMOOVE")
        )
        
    ),     
    
    fluidRow(class = "main-page",
             
            column(4,

                  source("./ui/side-bar.R", local=TRUE)$value

            ),

            column(8, class="page-pane",
                                        
                  source("./ui/body.R", local=TRUE)$value
                    
             )
             
    )
    
    
  )
)











