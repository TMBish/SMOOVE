# shinyUI(
navbarPage("SMOOVE",theme=shinythemes::shinytheme("sandstone"),

    tabPanel("PLAYER.",
    
    #source("./ui/nav-bar.R", local=TRUE)$value,
  
    # fluidRow(class = 'center-children title-bar',
      
    #     column(3,
    #       h1("SMOOVE")
    #     )
        
    # ),     
    
    # Shiny Dashboard CSS
    tags$head(
      includeCSS(file.path('www', path = "AdminLTE.css")),
      includeCSS(file.path('www', path = "shinydashboard.css")),
      includeCSS(file.path('www', path = "style.css"))
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











