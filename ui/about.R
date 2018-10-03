div(class="key-info-box pad-15 smooveinfo",

  fluidRow(

  	column(7,

  		div(class = "header-box",
    		h4("SMOOVE.")
  		),

		HTML("
		<p> I named this project after the one and only J-Smoove. The resilience and conviction of my NBA fandom was forged in the fire
		of Josh Smith bricks and missed defensive rotations. Ironically, I firmly belive that in today's era - and with much <b> much </b> more discipline - he
		would be one best centers in the league. He had the potential to be a more offensively talented and athletic Draymond Green. </p>

		<p> <b> v1 </b> of this project aims to replace my 10-20 daily basketball reference searches: providing a more usable, visual, and pithy implementation
		of that tool. <b> SMOOVE </b> uses the same powerful NBA Stats API as a back-end. </p>

		<p> I hope to continue development on the app regularly and aim to enable: <p>

		<ul>
		<li> Searching historical (non-active) players </li>
		<li> Expanded stat views to include advanced stats </li>
		<li> A team component to quantify stylistic differences across teams </li>
		<li> Various improvements to the functionality and interface </li>
		</ul>
		")

  	),

  	column(5,

		tags$img(id = "about-smoove",src = "smoove.jpg")
  	)

  )




)