div(class="key-info-box pad-15 smooveinfo",

  fluidRow(

    column(7,

        div(class = "header-box",
            h4("SMOOVE.")
        ),

        HTML("
        <p> 
        I named this project after the one and only J-Smoove. The resilience and stoicism of my NBA fandom was forged in the furnace
        of Josh Smith bricks and defensive lapses. As one of my most hated players of all time I do think, ironically, in today's era - and with much <b> much </b> more discipline - he
        would be one of the best 4/5s in the league. Elite finishing, shot blocking, and passing at 6'9\": he had the potential to be a more offensively talented, athletic Draymond Green. 
        </p>
        <p> 
        I hope <b> V1 </b> of this project replaces my 10-20 daily basketball reference searches. It intends to provide a more usable, visual, and compact implementation
        of that tool. <b> SMOOVE </b> uses the same powerful NBA Stats API as a back-end. 
        </p>
        <p> 
        I hope to continue development on the app regularly and aim to enable: 
        </p>
        <ul>
        <li> Searching historical (non-active) players </li>
        <li> Expanded stat views to include advanced stats </li>
        <li> A team component to quantify strength and stylistic differences across teams </li>
        <li> Various improvements to the functionality and interface </li>
        </ul>
        
        <p> All source code is available on <b> <a href = 'https://github.com/TMBish/SMOOVE'> Github </a> </b> and if you want to know more about me head to <b> <a href = 'http://www.tmbish.me/aboutme/'>tmbish.me</a></b>.
        ")

    ),

    column(5,
        tags$img(id = "about-smoove",src = "smoove.jpg")
    )

  )




)