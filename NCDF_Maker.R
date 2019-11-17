# Load libraries
library(ncdf4) 
library(RNetCDF)
library(abind)
library(tidyverse)
library(data.table)
library(doParallel)

datadir <- './flux/' # Define data directory
date_start <- '1945-01-01' # Start date of data
date_end <- '2012-12-31' # End date of data
missval <- -9999 # value for missing data
outfile <- 'vic_liard.nc' # Name of netcdf file
chunk_size <- 500 # Adjust according to RAM size

vars <- c('PREC', 'EVAP', 'RUNOFF', 'BASEFLOW', 'SWE', 'RAINF', 'SNOWF', 
          'PET', 'SOIL_MOISTURE1', 'SOIL_MOISTURE2', 'SOIL_MOISTURE3')
units <- c('mm','mm','mm','mm','mm','mm','mm','mm','mm','mm','mm')

create_ncdf <- function(..) { # Parent wrapper function
  
  fls <- list.files(path = datadir) # Read in file names without full path
  lon <- as.numeric(word(fls,-1,sep='_')) # Extract longitude from file name
  lat <- as.numeric(word(fls,2,sep="_")) # Extract Latitude from file name
  grid <- data.frame('lon' = lon, 'lat' = lat) # Create grid
  fls <- list.files(path = datadir,full.names = T) # Read in file names again with full paths
  grid$file <- fls # Add it to grid dataframe for later use
  
  # Create time dimension
  # Time dimension will be number of days since 1900-01-01
  t <- as.numeric(seq(as.Date(date_start), as.Date(date_end),1) - as.Date('1900-01-01'))
  nc_time <- ncdim_def('time', "Days since 1900-01-01", t, unlim=T)
  
  # Create space dimension
  lats <- sort(unique(grid$lat))
  lons <- sort(unique(grid$lon))
  space <- expand.grid(lat=lats, lon=lons)
  # Find which grids should be NA because of expand grid
  pos <- which(mapply(function(lat, lon) {any(grid$lat == lat & grid$lon == lon)}, space$lat, space$lon))
  pos_dim <- ncdim_def('position', units='count', vals=pos)
  lat_dim <- ncdim_def('lat', units='degrees_north', lats)
  lon_dim <- ncdim_def('lon', units= 'degrees_east', lons) 
  nc_pos_vars <- list(lat=lat_dim, lon=lon_dim, pos=pos_dim)
  dims <- list(nc_pos_vars$lon, nc_pos_vars$lat, nc_time) # This will be the dimension of the netcdf file
  
  # Create variables
  nvars <- length(vars)
  nc_vars <- list() # Place holder
  for (i in 1:nvars) { # Iterate over vars to create ncdf variables
    nc_vars[[i]] <- ncvar_def(vars[i], units[i], dims, missval=missval, compression=2)
  }
  
  nc <- nc_create(outfile, nc_vars) # Create the netcdf file
  nc_close(nc) # Close it (save it)
  
  nc <- open.nc(outfile, write=T) # Open with write permission
  var.def.nc(nc, 'geographic_wgs84', 'NC_CHAR', NA) # Add coordinate system
  close.nc(nc) # Close/save it
  
  ## This will control the overall metadata - This is hardcoded - does not depend on variable definition done earlier
  add_attributes <- function(nc) {
    # Add the attributes to the variables
    ncdf.attributes <- list("0"=list( #global attributes
      Conventions = 'CF-1.5', # Take reference of conventions from here - http://cfconventions.org/
      title = 'Gridded Flux Data for Liard Basin, generated from VIC Model',
      institution = 'Watershed Hydrology and Ecology Research Division, Environment and Climate Change Canada',
      'source' = 'VIC Hydrologic Model Run',
      history = paste('created', Sys.time()),
      reference = 'Rajesh R Shrestha, Research Scientist, Environment and Climate Change Canada',
      version = '1.0',
      'spatial_domain' = 'Square grid over Liard Basin',
      'grid_resolution' = '0.0625 degree grids',
      contact1 = 'rajesh.shrestha@canada.ca'
    ),
    lat = list('long_name' = 'latitude of grid cell centre',
               units = 'degrees_north',
               'standard_name' = 'latitude',
               axis = 'Y'
    ),
    lon = list('long_name' = 'longitude of grid cell centre',
               units = 'degrees_east',
               'standard_name' = 'longitude',
               axis = 'X'
    ),
    
    'geographic_wgs84' = list(
      'grid_mapping_name' = 'latitude_longitude',
      'longitude_of_prime_meridian' = 0.0,
      'semi_major_axis' = 6378137.0,
      'inverse_flattening' = 298.257223563
    ),
    time = list('long_name' = 'time',
                calendar = 'standard',
                'standard_name' = 'time',
                axis = 'T'),
    PREC = list('long_name' = 'Incoming precipitation',
                'standard_name' = 'Precipitation',
                units = 'mm',
                'cell_method' = 'time: sum (interval: 1 day)',
                'grid_mapping' = 'geographic_wgs84',
                'scale_factor' = 1,
                coordinates = 'lon lat'),
    EVAP = list('long_name' = 'Total net evaporation',
                'standard_name' = 'Evaporation',
                units = 'mm',
                'cell_method' = 'time: sum (interval: 1 day)',
                'grid_mapping' = 'geographic_wgs84',
                'scale_factor' = 1,
                coordinates = 'lon lat'),
    RUNOFF = list('long_name' = 'Surface runoff',
                  'standard_name' = 'Runoff',
                  units = 'mm',
                  'cell_method' = 'time: sum (interval: 1 day)',
                  'grid_mapping' = 'geographic_wgs84',
                  'scale_factor' = 1,
                  coordinates = 'lon lat'),
    BASEFLOW = list('long_name' = 'Baseflow out of the bottom layer',
                    'standard_name' = 'Baseflow',
                    units = 'mm',
                    'cell_method' = 'time: sum (interval: 1 day)',
                    'grid_mapping' = 'geographic_wgs84',
                    'scale_factor' = 1,
                    coordinates = 'lon lat'),
    SWE = list('long_name' = 'Snow water equivalent in snow pack (including vegetation-intercepted snow)',
               'standard_name' = 'Snow-Water Equivalent',
               units = 'mm',
               'cell_method' = 'time: sum (interval: 1 day)',
               'grid_mapping' = 'geographic_wgs84',
               'scale_factor' = 1,
               coordinates = 'lon lat'),
    RAINF = list('long_name' = 'Rainfall',
                 'standard_name' = 'Rainfall',
                 units = 'mm',
                 'cell_method' = 'time: sum (interval: 1 day)',
                 'grid_mapping' = 'geographic_wgs84',
                 'scale_factor' = 1,
                 coordinates = 'lon lat'),
    SNOWF = list('long_name' = 'Snowfall',
                 'standard_name' = 'Snowfall',
                 units = 'mm',
                 'cell_method' = 'time: sum (interval: 1 day)',
                 'grid_mapping' = 'geographic_wgs84',
                 'scale_factor' = 1,
                 coordinates = 'lon lat'),
    PET = list('long_name' = 'Potential evapotranspiration',
               'standard_name' = 'Evapotranspiration',
               units = 'mm',
               'cell_method' = 'time: sum (interval: 1 day)',
               'grid_mapping' = 'geographic_wgs84',
               'scale_factor' = 1,
               coordinates = 'lon lat'),
    SOIL_MOISTURE1 = list('long_name' = 'Total soil moisture content for layer 1',
                          'standard_name' = 'Soil Moisture',
                          units = 'mm',
                          'cell_method' = 'time: sum (interval: 1 day)',
                          'grid_mapping' = 'geographic_wgs84',
                          'scale_factor' = 1,
                          coordinates = 'lon lat'),
    SOIL_MOISTURE2 = list('long_name' = 'Total soil moisture content for layer 2',
                          'standard_name' = 'Soil Moisture',
                          units = 'mm',
                          'cell_method' = 'time: sum (interval: 1 day)',
                          'grid_mapping' = 'geographic_wgs84',
                          'scale_factor' = 1,
                          coordinates = 'lon lat'),
    SOIL_MOISTURE3 = list('long_name' = 'Total soil moisture content for layer 3',
                          'standard_name' = 'Soil Moisture',
                          units = 'mm',
                          'cell_method' = 'time: sum (interval: 1 day)',
                          'grid_mapping' = 'geographic_wgs84',
                          'scale_factor' = 1,
                          coordinates = 'lon lat')
    )
    for (var.name in names(ncdf.attributes)) {
      for (att.name in names(ncdf.attributes[[var.name]])) {
        value <- ncdf.attributes[[c(var.name, att.name)]]
        if (is.character(value))
          mode <- attprec <- 'text'
        else
          attprec <- 'float'
        if (var.name == '0') var.name <- 0
        ncatt_put(nc, var.name, att.name, value, attprec, definemode=T)
      }
    }
    return(nc)
  }
  
  nc <- nc_open(outfile, write=T)
  nc_redef(nc)
  nc <- add_attributes(nc) # Adding attributes to file
  nc_enddef(nc)
  
  read_data <- function(file,nt) { # file is a single flux file name, nt is length of time dimension
    nadf <- data.frame(array(missval, dim=c(nt, 11))) # return NA if grid outside shape of basin
    names(nadf) <- vars # needed for rbind later
    if (! file.exists(file)) { # If grid not in basin, the filename would not exist
      stopifnot(!is.na(nt))
      print(paste("File", file, "does not exist.  Returning MISSVALS"))
      return(nadf) # Return NA in that case
    }
    d <- fread(file) # fread from data.table (very fast)
    d <- data.frame(d[,4:14]) # Remove date columns
    names(d) <- vars # Name the columns
    return(d)
  }
  
  fill_lat_chunks <- function(nc, grid, chunk_size) { # Adds data to nc file in multiple lats at a time(chunk_size) 
    
    rownames(grid) <- paste(grid[,'lat'], grid[,'lon'], sep="_")
    nt <- nc$dim$time$len # Define length of time dimension
    lats <- nc$dim$lat$vals
    space.n <- nc$dim$lat$len * nc$dim$lon$len # Time * Lat dimension
    
    lon_chunk_size <- floor(chunk_size / nc$dim$lat$len) # How many lons to iterate over
    
    files <- grid$file # file names
    lon_start <- 1
    while (lon_start <= nc$dim$lon$len) {
      
      lon_end <- min(lon_start + lon_chunk_size - 1, nc$dim$lon$len) # Go until length exceeds
      lons <- nc$dim$lon$vals[lon_start:lon_end] # Pull out these many lons
      
      all_points <- expand.grid(lons, lats) # square space
      i <- paste(all_points[,2], all_points[,1], sep='_') # Multiple points
      files <- grid[i,'file'] # Pull out multiple filenames from the square space
      
      data <- lapply(files, read_data, nt) # Read in data from multiple files and put them in a list
      data <- abind(data, along=3) # bind the list along the third dimension
      names(dimnames(data)) <- c('time', 'var.name', 'space') # Name the dimensions
      ## Permute the array to (var.name, space, time)  so that we can do contiguous writes to the netcdf file (much faster)
      data <- aperm(data, c(2, 3, 1))
      
      gc() ## Clean up our mess
      
      for (var.name in dimnames(data)[['var.name']]) { # Pick up a single var
        print(paste("Writing", var.name, "values to netcdf"))
        n.to.write <- lon_end - lon_start + 1 # How many chunks to write
        rv <- try(ncvar_put(nc, var.name, data[var.name,,], start=c(lon_start,1,1), count=c(n.to.write,-1,-1)))
        if (inherits(rv, 'try-error')) # Debug errors
          browser()
      }
      rm(data)
      gc()
      lon_start <- lon_end + 1 # Repeat till end
    }
    
    nc_sync(nc)
    
    return(nc)
  }
  
  fill_lat_chunks(nc,grid,chunk_size) # Run the function
  nc_sync(nc) # Sync the data
  nc_close(nc) # Close the file
}

t1 <- proc.time()
create_ncdf(..)
t2 <- proc.time()
print(t2-t1)

rm(list=ls())
gc()
