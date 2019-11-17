# St. Lucia Project - WRR
# Initial aim: Find correlation between river level, sea level and rainfall

# Script 1 - Data cleaning
setwd('D:/WRR/')

#Load packages
packages <- c('tidyverse','data.table','pcaPP','copula','VineCopula','fitdistrplus','ggExtra','ggpubr','viridis','ggsci', 'lubridate','readxl')
lapply(packages, library, character.only = TRUE)

# Sea level data
  # Data is saved as csv, available in hourly time-step

sl_raw <- read.csv('ID 786_Roseau_ResearchVersion.csv', stringsAsFactors = F, header = T)
sl_raw$date <- as.Date(paste(sl_raw$Year,sl_raw$Month,sl_raw$Day,sep="-"))

# Remove unnecessary columns
sl_raw <- sl_raw[,c('date','SeaLevel.mm.')]
colnames(sl_raw) <- c('date','level')

# Convert to daily max ################## MAX ##################
sl_daily <- sl_raw %>% group_by(date) %>% summarise(level = max(level))

# Data has some wrong value (or maybe missing value denoted as -32767), remove them
sl_daily$level[sl_daily$level==-32767] <- NA
sl_miss_dates <- sl_daily$date[is.na(sl_daily$level)]
# Data is missing from july 5, 2013 to august 15, 2013 (42 days)
sl_daily <- na.omit(sl_daily)

###############################################################################################################################

# Streamflow data
  # Data is saved as xlsx. Available at daily time-step

q_raw <- read_xlsx('Simulated Streamflow.xlsx', col_names = T, skip = 3) 
q_raw$date <- as.Date(paste(q_raw$YEAR,q_raw$MONTH,q_raw$DAY,sep="-"))
# Remove unnecessary columns
q_raw <- q_raw[,c(7,6)]
colnames(q_raw) <- c('date','level')
# Data is sorted by level, sort it by date
q_daily <- q_raw[order(as.Date(q_raw$date, format="%Y/%m/%d")),]
q_daily <- na.omit(q_daily) # Only last two dates missing
# otherwise complete data from 1998 - 2018

###############################################################################################################################

# Rainfall data

fls <- list.files(path = './Rain/', pattern = '*.xls', full.names = T)
fls <- fls[-length(fls)] # Remove incomplete 2019 file
data_cleaner <- function(f) {
  print(f)
  yr <- substr((word(f,-1,sep="R")),1,4) # Extract year from file name
  d <- data.frame(read_xls(f, col_names = F, range = "A1:M40")) # Read specific area of cells
  start_row <- which(d[,2] == 'JAN') # Identify start row
  end_row <- which(d[,1] == 'TOTAL' | d[,1] == 'SUM')-1 # Identify last row
  if(is.na(d[,1][end_row])) {end_row <- end_row - 1} # If last row NA, move last row to previous
  d <- d[start_row:end_row,2:13] # Clip the cells to desired area
  colnames(d) <- d[1,] # Move 1st row to colnames (month names)
  d <- d[-1,] # Remove month name row now
  if(yr == 1998) {d[33,11] <- 0} # 30th November of 1998 missing
  pvec <- c() # Create empty vector
  # Loop to put each month one after the other to create 1 vector from 12 columns
  for (i in 1:12) { # Each month
    p <- d[,i]
    p[which(p=='T')] <- 0.01 # Replace Trace flag with 0.01mm
    p <- as.numeric(p) # Convert to numeric
    p <- na.omit(p)
    pvec <- append(pvec,p)
  }
  # Handle outliers - Replace anything above 5*SD with 5*SD and add random noise centered around 10
  pvec[which(pvec > sd(pvec)*5)] <- (sd(pvec)*5) + rnorm(1,10,2)
  
  df <- data.frame(
    'yr' = rep(yr,length(pvec)),
    'pr' = pvec
  )
  return(df)
}
dls <- lapply(fls, data_cleaner)
p_daily <- data.frame(do.call(rbind,dls))
p_daily$yr <- seq(as.Date('1998-01-01'), as.Date('2018-12-31'),1)
rm(list=setdiff(ls(), c('p_daily','q_daily','sl_daily')))
###############################################################################################################################
# Data processing done

# Analyse data now

# Join to lowest date range (sea level)
ddf <- inner_join(sl_daily,q_daily,'date')
colnames(p_daily)[1] <- 'date'
ddf <- inner_join(ddf,p_daily,'date')
ddf <- data.frame(ddf)
colnames(ddf) <- c('date','sl','qq','pr')
rm(list=setdiff(ls(), c('ddf')))

# Anamolies from the mean?
#ddf_anamoly <- data.frame(ddf %>% mutate(sl = sl-mean(sl), qq = qq-mean(qq), pr = pr-mean(pr)))
