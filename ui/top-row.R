# fluidRow(
#   column(3,
#          valueBoxOutput("vb_points")
#   ),
# 
#   column(3,
#          valueBoxOutput("vb_rebounds")
#   ),
# 
#   column(3,
#          valueBoxOutput("vb_assists")
#   ),
# 
#   column(3,
#          valueBoxOutput("vb_to")
#   )
# )

fluidRow(

         valueBoxOutput("vb_points"),

         valueBoxOutput("vb_rebounds"),

         valueBoxOutput("vb_assists")

         # valueBoxOutput("vb_to")
         
)