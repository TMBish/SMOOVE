library(taskscheduleR)

taskscheduler_delete("daily-smoove-data-update")


taskscheduler_create(
  "daily-smoove-data-update",
  rscript = "C:\\Data\\SCRIPTS\\daily-build.R",
  schedule = "DAILY", 
  starttime = "16:00", 
  startdate = format(Sys.Date(), "%d/%m/%Y")
)