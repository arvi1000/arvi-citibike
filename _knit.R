# source files
src_fls <-
  c("0_download_data.R", "1_load_data.R", "2_descriptive_viz.R",
    "3_station_map_setup.R", "4_station_traffic.R", "5_top_trips.R",
    "6_nsew_trips.R", "7_volume_flux.R")

# careful, this will take a long time to run!
#sapply(src_fls, source)

# knit
library(knitr)
library(gridExtra)
knit2html('output.Rmd', 'output.html', 
          stylesheet='css/markdown_modified.css')

