
# start and end volume by station----
start_end_N <- 
  merge(trips[, list(start_N=.N), by=list(station_id=start_station_id)],
        trips[, list(end_N=.N), by=list(station_id=end_station_id)],
        by='station_id')
start_end_N[, diff:=end_N/start_N-1]
start_end_N <- merge(start_end_N, station_info, by='station_id')
start_end_N[, mean_N:=mean(c(start_N, end_N)), by=station_id]

# plot station volume, with start and end size
station_traffic_gg <-
  dark_crop_base +
  geom_point(data=start_end_N, 
             aes(x=station_lon, y=station_lat, size=mean_N, fill=diff), 
             shape=21, alpha=.8) +
  scale_fill_gradient2() +
  labs(size='Average Traffic\n(depatures / returns)',
       fill='% more returns')