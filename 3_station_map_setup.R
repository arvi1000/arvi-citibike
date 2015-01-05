library(ggmap)
library(lubridate)

# station id list: force station ID with non-unique info to most common value
station_cols <- grep('start_station', names(trips), value=T)
station_info <- trips[, .N, by=eval(station_cols)]
winners <- station_info[, N==max(N), by=start_station_id][, which(V1)]
station_info <- station_info[winners, station_cols, with=F]

# rename 'start_station...' to 'station...'
setnames(station_info, old=station_cols, new=gsub('start_', '', station_cols))

# ditch helper objects
rm(winners, station_cols)

# map center (mid point of lat/lon ranges)
map_center <- 
  unlist(station_info[, lapply(.SD, function(x) mean(range(x))), 
                      .SDcols=c('station_lon', 'station_lat')])

# get map
nyc_base <- qmap(location=map_center, 
                 source='google', maptype='roadmap', color='bw', zoom=12)

# function to extend a range (to get the map bounding box plus a bit of space
# on each side)
spread <- function(vec2, spread_factor=1.1) {
  half_diff <- abs(vec2[2] - vec2[1])/2
  c(mean(vec2) - half_diff*spread_factor,
    mean(vec2) + half_diff*spread_factor)
}

# get a 'bounding box plus': move x ends 20% from center, y 10%
bbox_plus <- c(spread(range(station_info$station_lon), 1.2),
               spread(range(station_info$station_lat), 1.1))

# a base map cropped to stations of interest, and darkened
dark_crop_base <-
  nyc_base +
  geom_rect(xmax=bbox_plus[2], xmin=bbox_plus[1],
            ymax=bbox_plus[4], ymin=bbox_plus[3],
            fill='black', alpha=.3)  +
  coord_map(projection="mercator", xlim=bbox_plus[1:2], ylim=bbox_plus[3:4])