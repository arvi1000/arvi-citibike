library(ggplot2)
library(magrittr)

### trip duration----

# function to convert from secs to mins and bin by X min intervals up to Y mins
bin_mins <- function(secs, bin_size=5, max_bin=120) {
  pmin(floor(secs/60/bin_size)*bin_size, max_bin)
}

# histogram
dur_gg <-
  # calculate share of trips by trip duration
  trips[, .(pct=.N/nrow(trips)), by=.(bin_mins(tripduration))] %>%
  # and plot
  ggplot(., aes(x=bin_mins, y=pct)) + 
  geom_line(color='grey') + geom_point(size=2) +  
  scale_x_continuous(breaks=seq(0,120,10), 
                     labels=c(paste('below', seq(5,120,10)), '120 +')) +
  theme_bw() +
  theme(panel.grid.minor=element_blank(),
        axis.text.x=element_text(angle=45, hjust=1)) +
  labs(x='Trip duration (mins)', y='Proportion of all trips',
       title='Trips by duration')
# cdf
dur_cdf_gg <-
  # calculate cumulative share of trips by trip duration
  trips[, .(pct=.N/nrow(trips)), by=.(bin_mins(tripduration))][
    order(bin_mins), .(bin_mins, cdf=cumsum(pct))] %>%
  # and plot
    ggplot(., aes(x=bin_mins, y=cdf)) + geom_line() +
    scale_x_continuous(breaks=seq(0,120,10), 
                       labels=c(paste('below', seq(5,120,10)), '120 +')) +
    scale_y_continuous(breaks=seq(0, 1, .2)) +
    theme_bw() +
    theme(axis.text.x=element_text(angle=45, hjust=1)) +
    labs(title='CDF of all trips', y='Proportion of all trips',
         x='Trip duration (mins)')

### seasonality----

# trips by weekday and month
trips_seasonal <- 
  trips[, .N, by=.(day=weekdays(starttime, abbreviate=T),
                   month=months(starttime, abbreviate=T))]

# sorted factor levels
trips_seasonal[, `:=`(day=factor(day, levels=c("Mon", "Tue", "Wed", "Thu", 
                                               "Fri", "Sat", "Sun")),
                      month=factor(month, levels=month.abb[c(7:12,1:6)]))]

# plot
seasons_gg <- 
  ggplot(trips_seasonal, aes(x=day, y=N/1000, color=month, group=month)) +
  geom_line() + facet_wrap(~month) +
  scale_color_discrete(guide=F) +
  theme_bw() +
  theme(panel.grid.minor=element_blank(),
        axis.text.x=element_text(angle=45, hjust=1)) +
  labs(title='Trip Volume by weekday and month, Jul 2013-Jun 2014',
       x='Day of Week', y='Trips (000s)')

### demographics----

# gender to labeled factor (1=Male)
trips[, fac_gender:=factor(gender, levels=1:2, labels=c('M', 'F'))]

# trips by age and gender
sub_demos <- 
  trips[usertype=='Subscriber', .N, 
        by=.(usertype,fac_gender,age=year(starttime) - as.numeric(birth_year))]

demo_gg <-
  ggplot(sub_demos[!is.na(age),], aes(x=age, y=N/1000, fill=fac_gender, order=fac_gender)) +
  geom_bar(stat='identity', position='stack') +
  theme_bw() +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  scale_x_continuous(breaks=seq(10, 110, 10)) +
  scale_fill_brewer(type='qual', palette=3) +
  labs(title='Subscriber Trips by Rider Age and Gender', fill='Gender',
       y='Trips (000s)')