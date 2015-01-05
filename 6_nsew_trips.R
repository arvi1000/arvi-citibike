
# assign cardinal dirs  

main_dir <- Vectorize(function(lat1, lat2, lon1, lon2) {
  # this is a hack to see if distance traveled is mostly N, E, S or W
  # At lat 40.72: 1 lat degree=69 mi and 1 lon deg=52.5 mi
  # (these constants from: www.csgnetwork.com/degreelenllavcalc.html)
  
  if(abs(lat2-lat1)*69 >= abs(lon2-lon1)*52.5) {
    ifelse(lat2-lat1 >=0, 'S', 'N')
  } else {
    ifelse(lon2-lon1 >=0, 'W', 'E')
  }
})

top_trips[start_station_id!=end_station_id & N>=500,
          nsew:=main_dir(start_station_lat, end_station_lat,
                         start_station_lon, end_station_lon)]
top_trips[, nsew:=factor(nsew, levels=c('N', 'S', 'E', 'W'))]

# non round trips
nsew_trips_gg <- 
  dark_crop_base +
  geom_segment(data=top_trips[!is.na(nsew),],
               aes(x=start_station_lon, y=start_station_lat,
                   xend=end_station_lon, yend=end_station_lat,
                   color=nsew, alpha=N), #alpha=log(N)), 
               size=0.5) +
  #arrow=arrow(angle=10, length=unit(0.01, 'npc'))) +
  scale_alpha_continuous('Total trips',
                         #breaks=log(seq(500, 3000, 500)), 
                         breaks=seq(500, 3000, 500), 
                         labels=seq(500, 3000, 500)) +
  scale_fill_discrete(guide=F) +
  facet_wrap(~nsew) +
  labs(title='Most popular trips, Jul-13 to Jun-14
         (faceted by main cardinal direction)')