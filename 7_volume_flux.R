  
# station capacity from system data / offline version: source('_get_sysdata.R')
library(jsonlite)
sys_dat <- fromJSON('http://www.citibikenyc.com/stations/json')
sys_df <- data.table(sys_dat$stationBeanList)
sys_df[, list(station_id=id, totalDocks)]

# params
time_window <-
  which(trips[, starttime >= ymd('2014-06-01', tz='America/New_York') &
                  starttime < ymd('2014-06-08', tz='America/New_York')])
set.seed(1)
plot_stns <- station_info$station_id[sample(1:nrow(station_info), 9)]

# data
flux <- rbind(trips[time_window, .(flow = -1),
                    by=.(at_time=starttime, station_id=start_station_id)],              
              trips[time_window, .(flow = 1), 
                    by=.(at_time=stoptime, station_id=end_station_id)])
flux <- flux[order(at_time, station_id),]
flux <- flux[, list(at_time, flow, bikes=cumsum(flow)), by=station_id]

# extract date range for title
date_range <- paste(trunc(trips$starttime[time_window[1]], 'days'), 'to',
                    trunc(trips$starttime[last(time_window)], 'days'))
# plot
bike_flux_gg <-
  ggplot() + 
    geom_line(data=flux[station_id %in% plot_stns,],
              aes(x=at_time, y=bikes, color=factor(station_id))) + 
    geom_hline(data=sys_df[id %in% plot_stns, list(station_id=id, totalDocks)],
               aes(yintercept=totalDocks, group=factor(station_id))) +
    geom_hline(data=sys_df[id %in% plot_stns, list(station_id=id, totalDocks)],
               aes(yintercept=-totalDocks, group=factor(station_id))) +
    facet_wrap(~station_id) +
    scale_color_discrete(guide=F) +
    ggtitle(paste0('Net Bike Traffic for selected stations,\n', date_range)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle=45, hjust=1))


