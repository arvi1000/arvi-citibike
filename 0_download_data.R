# url source
url_stem <- 'https://s3.amazonaws.com/tripdata/'
url_suffix <- '-citibike-tripdata.zip'
date_strs <- c(paste0('2013', sprintf('%02d', c(7:12))),
               paste0('2014', sprintf('%02d', c(1:6))))
         
file_urls <- paste0(url_stem, date_strs, url_suffix)

# download files
dir.create('data')

for (i in 1:length(file_urls)) {
  now <- Sys.time()
  cat('Downloading file', i, '\n\t', file_urls[i], '\n')
  download.file(url=file_urls[i], 
                destfile=paste0('data/', date_strs[i], url_suffix),
                method='curl', quiet=T)
  cat('\t Done! Time elapsed:', Sys.time() - now, '\n')
}

# unzip
dir.create('data/csv')
sapply(paste0('data/', date_strs, url_suffix), unzip, exdir='data/csv')
