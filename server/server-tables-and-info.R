# ++++++++++++++++++++++++
# DYNAMIC INPUTS
# ++++++++++++++++++++++++

output$player_search = renderUI({
  
  req(revals$player_master)
  
  player_master = revals$player_master
  
  # Default
  if (!(is.null(revals$player_name))) {
    inputvalue = revals$player_name
  } else {
    inputvalue = player_master %>% sample_n(1) %>% pull(player)
  }
  
  shinyTypeahead::typeaheadInput(
      "player_name", label = "",
      items = 15,
      value = inputvalue,
      choices = player_master$player
  )
  
})

# Unhide selection
observe({
  req(revals$player_master)
  
  show("player-search-row", anim =TRUE)
  
})


# ++++++++++++++++++++++++
# TABLES
# ++++++++++++++++++++++++

# Player Stat Overview Table
output$player_stat_table = renderDT({
  
  req(revals$player_stat_table)
  req(revals$season)
  
  # Label for the per mode
  per_mode_label = ifelse(input$per_36_enable, "PER 36 MINUTES", "PER GAME")
  
  # Insert statistic into rownames and reverse peer percentile
  dtab = 
    revals$player_stat_table %>% 
    mutate(
      peer_percentile = case_when(
        statistic == "Turnovers" ~ (100 - peer_percentile),
        TRUE ~ peer_percentile
      )
    ) 
  dtab = dtab %>% as.data.frame()
  rownames(dtab) = dtab$statistic
  dtab = dtab %>% select(-statistic)
    
  # Create custom column names for the per mode
  column_container = htmltools::withTags(table(
    class = 'display dt-center',
    thead(
      tr(
        th(rowspan = 2, ""),
        th(colspan = 4, per_mode_label)
      ),
      tr(
        lapply(c(revals$season, "Peers", "Peer %tile", "Career Avg"), th)
      )
    )
  ))
  
  datatable(
    dtab
    , elementId = "dt-player-overview-table"
    , container = column_container
    , selection = "none"
    , class = 'compact hover row-border'
    , escape = FALSE
    , options = list(
      dom = 't',
      pageLength = 20,
      columnDefs = list(
        list(className = 'dt-right', targets = c(1, 2, 4)),
        list(className = 'dt-center', targets = 3),
        list(className = "dt-left", targets = 0)
      )
    )
  ) %>%
  formatStyle(
    0,
    target = 'row',
    # fontWeight = styleEqual(
    #   c("Points", "FG %", "3PT %", "FT %", "Rebounds", "Assists", "Turnovers")
    #   , rep("bold", 7)
    # ),
    borderBottom=styleEqual(
      c("Points", "FG %", "3PT %", "FT %", "Rebounds", "Turnovers"),
      rep("1.7px solid #3e3f3a", 6)
    )
  ) %>% 
  formatStyle(
    'peer_percentile',
    backgroundColor = styleInterval(c(15, 40, 60, 85), c('rgba(29,137,255,0)', "rgba(29,137,255,0.15)", 'rgba(29,137,255,0.4)', 'rgba(29,137,255,0.6)', 'rgba(29,137,255,0.85)'))
    ,color = styleEqual(NA, "white")
  )
  
  
})

# ++++++++++++++++++++++++
# INFO OUTPUTS
# ++++++++++++++++++++++++

output$core_player_name = renderText({
  req(revals$player_name)
  revals$player_name
})
output$eff_player_name = renderText({
  req(revals$player_name)
  revals$player_name
})

output$player_info = renderUI({
  
  req(revals$player_data)
  req(revals$position)
  req(revals$starter_bench)
  
  pos_ = case_when(
    revals$position == "F" ~ "Forwards",
    revals$position == "G" ~ "Guards",
    TRUE ~ "Centers"
  )
  
  txt =
    revals$player_data %>%
    mutate(
      info = glue("
        <b> Height: </b> {height} <br>
        <b> Weight: </b> {weight} lbs <br>
        <b> Age: </b> {age} <br>
        <b> College: </b> {school} <br>
      ")
    ) %>%
    pull(info)

  glue("<b> Peer Group: </b> {revals$starter_bench} {pos_} <br> {txt}") %>%
  HTML()

})

output$player_photo = renderUI({
  
  req(revals$player_id)
  
  shiny::img(src = paste0("https://ak-static.cms.nba.com/wp-content/uploads/headshots/nba/latest/260x190/",revals$player_id,".png"))
  
})
