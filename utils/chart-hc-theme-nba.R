hc_theme_nba = function() {
  
  base_font = "Bitter"
  header_font = "Bitter"
  
  header_style = list(fontFamily = header_font, fontWeight = "bold", color = "#000000")
  
  out = 
    hc_theme(
      chart = list(
        backgroundColor = "#FFF",
        style = list(
          fontFamily = base_font
        )
        # shadow = TRUE
      ),
      colors = list("#0e1111", "#1d89ff", "#ED074F", "#FE5F55", "#C1E1F1", "#5FEF9B"),
       # "#1D428A", 
      title = list(
        style = header_style,
        align = "left"
      ),
      xAxis = list(
        lineWidth = 1, lineColor = "#011627",
        tickWidth = 0,
        title = list(style = header_style),
        labels = list(autoRotation = 0, overflow = "justify")
      ),
      yAxis = list(
        lineWidth = 1, lineColor = "#011627",
        tickWidth = 0,
        title = list(style = header_style)
      ),
      subtitle = list(
        style = list(fontStyle = "italic", color ="#000000"), 
        align = "left"
      ),
      tooltip = list(
        shape = "square",
        valueDecimals = 2,
        backgroundColor = "#FFF",
        valueDecimals = 2,
        headerFormat = ""
      ),
      plotOptions = list(
        line = list(marker = list(symbol = "circle", lineWidth = 3, radius = 2)),
        scatter = list(marker = list(symbol = "square", radius = 3)),
        spline = list(marker = list(symbol = "circle", lineWidth = 2, radius = 0)),
        column = list(dataLabels = list(backgroundColor = "#FFF"))
      ),
      legend = list(
        align = "right",
        layout = "vertical",
        backgroundColor = "#FFF",
        shadow = TRUE,
        title = "Legend",
        verticalAlign = "middle"
      )
    )
}