# top trips----
top_trips <- 
  trips[, .N, by=eval(grep('station', names(trips), value=T))][order(-N)]

# how many are round trips?
top_trips_table <- 
  top_trips[, .(trips=sum(N), trips_pct=round(sum(N)/nrow(trips), 3)), 
            by=.(round_trip=start_station_id==end_station_id)]

# trips and roundtrips
top_trips_gg <-
  dark_crop_base +
  geom_segment(data=top_trips[1:20,][start_station_id!=end_station_id,],
               aes(x=start_station_lon, y=start_station_lat,
                   xend=end_station_lon, yend=end_station_lat,
                   color='Point to point trips')) + #sneaky dummy mapping to get legend to show up
  geom_point(data=top_trips[1:20,][start_station_id==end_station_id,],
             aes(x=end_station_lon, y=end_station_lat,
                 size='Round trips'),  #sneaky dummy mapping to get legend to show up
             shape=21, color='red') +
  scale_size_manual(name='', values=3) +
  scale_color_manual(name='', values='red') + 
  labs(title='Top 20 most popular Citi Bike Trips')