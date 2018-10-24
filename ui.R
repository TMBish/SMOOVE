# shinyUI(
navbarPage("SMOOVE",
           
    tabPanel("PLAYER.", useShinyjs(),
    
    # Shiny Dashboard CSS
    tags$head(
      includeCSS(file.path('www', path = "AdminLTE.css")),
      includeCSS(file.path('www', path = "shinydashboard.css")),
      includeCSS(file.path('www', path = "style.css"))
    ),
    
    hidden(
        
        div(id = "loading-container", tags$img(src = "loader.gif", id = "loading-spinner"))
    
    ),
    
    fluidRow(class = "main-page",
             
             
            column(4,
                  source("./ui/side-bar.R", local=TRUE)$value
            ),

            column(8, class="page-pane",
                  source("./ui/body.R", local=TRUE)$value      
             )
    )
  ),
  
  tabPanel("ABOUT.", 
    source("./ui/about.R", local=TRUE)$value       
  )
)











