library(data.table)
fpath <- 'data/csv/'
rds_fl <- 'data/trips.rds'

start_time <- Sys.time()

# read from r binary file if it's already created,
# ...otherwise assemble from csv files

if (file.exists(rds_fl)) {
  cat('Loading from RDS object...\n')
  trips <- readRDS(rds_fl)
  rm(rds_fl, fpath)
  
} else {
  
  cat('Loading from csv files...\n')
  csv_fls <- grep('csv', list.files(fpath), value=T)
  
  # empty list for all the trip files
  trip_dts <- list()
  
  # load each file
  for (i in seq_along(csv_fls)) {
    
    cat('** Loading file', i, 'of', length(csv_fls), '|', csv_fls[i], '\n')
    
    # get data
    trip_dts[[i]] <- fread(paste0(fpath, csv_fls[i]))
    
    # tidy names
    setnames(trip_dts[[i]], gsub(' ', '_', names(trip_dts[[i]])))
    setnames(trip_dts[[i]], gsub('latitude', 'lat', names(trip_dts[[i]])))
    setnames(trip_dts[[i]], gsub('longitude', 'lon', names(trip_dts[[i]])))
    
    # convert to numeric
    num_cols <- grep('lat|lon|duration|id$', names(trip_dts[[i]]), value=T)
    trip_dts[[i]][, (num_cols):=lapply(.SD, as.numeric), .SDcols=num_cols]
  }
  
  #bind it all together
  trips <- rbindlist(trip_dts)
  
  # convert char date to posixct
  library(lubridate)
  trips[, starttime:=ymd_hms(starttime, tz='America/New_York')]
  trips[, stoptime:=ymd_hms(stoptime, tz='America/New_York')]
  
  # save object for fast loading later
  saveRDS(trips, file=rds_fl)
  
  # ditch helper objects
  rm(trip_dts, i, num_cols, rds_fl, fpath)
  
}

cat('Done. Elapsed time:', Sys.time()-start_time, units(Sys.time()-start_time))
rm(start_time)