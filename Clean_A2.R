##### Almost generic script for data cleaning of Assignment 2 (Advanced Hydroscience)

# Load libraries
library(tidyverse)
library(lubridate)

# Set working directory
setwd('D:/Example/Input/')

# All input fiels are in a folder named EC
file_names <- list.files(path = './EC/', full.names = T)

# Function to clean the data
read_data <- function(fname) {
  print(fname)
  
  raw_data <- read_delim(fname, delim = ',', skip = 1) # Read data, skip the first problematic row
  date_vector <- raw_data$` time` # Extracting the date column separately
  raw_data$` time` <- NULL # Removing the date column from the original table
  
  # Clean 'none' values in all columns.
  
  column_cleaner <- function(col) {
    col[which(col == 'None')] <- NA # Change 'None' to NA because 'None' is a character
    col <- as.numeric(col) # Convert to numeric now
    return(col)
  }
  
  processed_data <- data.frame(sapply(raw_data, column_cleaner)) # Iterate over all columns
  
  if (dim(processed_data)[2] != 6) { # Some files dont have tasmax and tasmin, we dont want those files
    return(NA)
  }
  
  colnames(processed_data) <- c('Pr', 'Rain', 'Tasmin', 'Snow', 'Snow_G', 'tasmax') # Give meaningful column names
  
  processed_data$date <- as.Date(date_vector) # Add back the data column
  
  if(min(year(date_vector)) >= 1971 & max(year(date_vector)) <= 2000) { # Selection of minimum range of data. Change accordingly
    return(NA)
  }
  
  return(processed_data)
}

processed_list <- lapply(file_names, read_data) # All processed files
na_stations <- which(is.na(processed_list)) # Store which elements are NA. We will need them later
processed_list <- processed_list[-na_stations] # emove the NA elements.

# Aggregate the data from Oct - March

mean_fun <- function(d) {
  d <- d %>% filter(year(date) >= 1971 & year(date) <= 2000) # Filter the data range
  d2 <- d # save a copy to average snow data later
  d <- d %>% filter(month(date) %in% c(10,11,12,1,2,3)) # Filter Oct - March
  mean_tasmax <- mean(d$tasmax, na.rm=T) # Ignore NA. (Only because its an assignment. Handle them carefully in applied research)
  mean_tasmin <- mean(d$Tasmin, na.rm=T)
  mean_pr <- mean(d$Pr, na.rm=T)
  mean_tmp <- mean(c(mean_tasmax, mean_tasmin))
  
  # Now use that d2 copy to average snow
  d2 <- d2 %>% filter(month(date) == 4 & day(date) == 1) # Filter April 1
  mean_snow <- mean(d2$Snow_G, na.rm=T) # Now find the mean
  
  
  return(c(mean_tmp, mean_pr, mean_snow)) # Return the data
}

q4_data <- lapply(processed_list, mean_fun) # Separate list for each file
q4_data <- data.frame(do.call(rbind, q4_data)) # Combine them to create one unified table


# Now we want to match this data to the station from which it comes
# First, we will extract the station name from the file name, using substr function
d <- substr(file_names,7,13) # The start position (7)  and end position (13) to clip the string could be different if you have a different path
d <- d[-na_stations] # Remove the NA from the stations (we stored these earlier)
d <- data.frame(native_id = d) # Create a dataframe, name the column "native_id" (see further why)

raw_csv <- read.csv('./crmp_network_geoserver-2.csv', header = T, stringsAsFactors = F) # This is the metadata file you downloaded which has station names, lat/lon etc
raw_csv <- raw_csv[,c(3,5,6,7)] # Take out station name, lat, lon and elevation columns

# Now we do an inner join (remember Venn diagrams). 
# For this, you need two dataframes that have a common column name (native_id) which you want to match
# When you inner join them, it will merge the two dataframes into one, bringing matching information from both tables into one table, based on the common values in the native_id column
common <- inner_join(d, raw_csv, 'native_id')
common <- common %>% group_by(native_id) %>% summarise(lon = mean(lon), lat = mean(lat), elev = mean(elev)) # There are repetitive entries for some stations (no idea why). Simply take their mean (again, dont do this in applied research)

# Now create you r final table
final_df <- data.frame(
  pr = q4_data$X2,
  tmp = q4_data$X1,
  snow = q4_data$X3,
  lon = common$lon,
  lat = common$lat,
  elev = common$elev,
  sid = common$native_id
)
write.csv(final_df,'ResultQ4.csv') # Write it out