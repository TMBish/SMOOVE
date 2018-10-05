# ++++++++++++++++++++++++
# TABLES
# ++++++++++++++++++++++++

# Player Stat Overview Table
output$player_stat_table = renderDT({
  
  req(revals$player_stat_table)
  
  # Label for the per mode
  per_mode_label = ifelse(input$per_36_enable, "PER 36 MINUTES", "PER GAME")
  
  # Insert statistic into rownames
  dtab = revals$player_stat_table %>% as.data.frame()
  rownames(dtab) = dtab$statistic
  dtab = 
    dtab %>% 
    select(-statistic)
    
  # Create custom column names for the per mode
  column_container = htmltools::withTags(table(
    class = 'display dt-center',
    thead(
      tr(
        th(rowspan = 2, ""),
        th(colspan = 4, per_mode_label)
      ),
      tr(
        lapply(c("Career Avg", "2017-18", "Peer Median", "Peer %tile"), th)
      )
    )
  ))
  
  datatable(
    dtab
    , container = column_container
    , selection = "none"
    , class = 'compact hover row-border'
    , escape = FALSE
    , options = list(
      dom = 't',
      pageLength = 20,
      columnDefs = list(
        list(className = 'dt-center', targets = c(1, 2, 3, 4)),
        list(className = "dt-right", targets = 0)
      )
    )
  ) %>%
  formatStyle(
    'peer_percentile',
    backgroundColor = styleInterval(c(15, 40, 60, 85), c('rgba(29,137,255,0)', "rgba(29,137,255,0.15)", 'rgba(29,137,255,0.4)', 'rgba(29,137,255,0.6)', 'rgba(29,137,255,0.85)')),
    color = styleInterval(c(60), c("#000", "#FFF"))
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
