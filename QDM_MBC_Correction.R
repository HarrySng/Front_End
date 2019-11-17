######################################################################################
#                       Univariate vs Multivariate Bias Correction                   #
#                               Created By: Harry Singh                              #
#                                 Date: Aug-01-2019                                  #
######################################################################################

# Objective
# 1 observed dataset (AHCCD)
# 5 gridded products
# Do univariate bias correction of gridded products (Quantile Delta Mapping)
# Do multivariate bias correction of gridded products (MBCr) (Alex Cannon, 2016)
# Compare effects (Different script)

# Load libraries
library(MBC)
library(lubridate)
library(tidyverse)

# Load data
data_list <- readRDS('D:/PAPER2/Raven_biv/raw_klk_tmp_pr.rds')
obs_data <- data_list[[2]] # Observation dataset (The 1st element is gauge data, only need it later for streamflow)
mdl_list <- data_list[3:7] # Gridded products


######################## Primary function Block ########################
bias_corr_wrapper <- function(mdl_data) { # mdl_data is a gridded product
  
  # Split data by years
  annual_split <- function(m) {
    m <- data.frame(m)
    m$date <- seq(as.Date('1980-01-01'),as.Date('2010-12-31'),1)
    m <- split(m, year(m$date))
    return(m)
  }
  obs <- annual_split(obs_data) # obs is a list of 31 years of observed data
  mdl <- annual_split(mdl_data) # mdl is a list of 31 years of gridded data
  
  # Function to iterate over years
  annual_wrapper <- function(o.y,m.y) { # Iterate over obs, mdl
    # Split into months
    o.y <- split(o.y, month(o.y$date))
    m.y <- split(m.y, month(m.y$date))
    
    # Function to iterate over months
    monthly_wrapper <- function(o.m, m.m) { # Iterate over o.y, m.y
      o.m <- as.matrix(o.m[,1:2])
      m.m <- as.matrix(m.m[,1:2])
      f.m <- m.m # Fake future data
      f.m[,1] <- f.m[,1] + rnorm(length(f.m[,1]),mean=0,sd=2) # Add noise to temp
      f.m[,2] <- f.m[,2] + runif(length(f.m[,2]),min = 0.1, max = 1.0) # Add positive noise to pr
      
      print('running bias correction')
      
      # Univariate bias correction
      qdm_wrapper <- function(k) { # Run separately on each vector 
        if (k == 2) {ratio=T
        } else {ratio=F}
        
        qdm <- QDM(o.m[,k], m.m[,k], f.m[,k], 
                   ratio=ratio, 
                   jitter.factor=0.0001, 
                   ties='first')
        
        return(qdm[[1]])
      }
      qdm_mdl <- sapply(1:2, qdm_wrapper) # Matrix of tmp, pr - corrected univariately
      
      # Multivariate bias correction - Run together on tmp, pr matrix
      mbc.r <- MBCr(o.m, m.m, f.m,
                    iter = 100, 
                    cor.thresh = 0.0001,
                    ratio.seq=c(FALSE,TRUE), 
                    ties = 'first',
                    jitter.factor=0.0001,
                    silent = T)
      
      mbc_mdl <- mbc.r[[1]]
      
      return(list(qdm_mdl, mbc_mdl)) # Return a list of univariate and multivariate bias corrected data
    }
    
    corrected_monthly <- lapply(1:12, function(i) monthly_wrapper(o.y[[i]], m.y[[i]]))
    # A list of 12 (months) and nested 2 (uni and multi corrected)
    
    # Separate uni and multi
    uni_data <- list()
    multi_data <- list()
    for (i in 1:12) { 
      uni_data[[i]] <- corrected_monthly[[i]][[1]]
      multi_data[[i]] <- corrected_monthly[[i]][[2]]
    }
    
    uni_data <- do.call(rbind, uni_data) # Bind back to annual
    multi_data <- do.call(rbind, multi_data) # Bind back to annual
    
    return(list(uni_data, multi_data))
  }
  corrected_annual <- lapply(1:31, function(i) annual_wrapper(obs[[i]], mdl[[i]]))
  # A list of 31 (years) and nested 2 (uni and multi corrected)
  
  # Separate uni and multi
  uni_data <- list()
  multi_data <- list()
  for (i in 1:31) { 
    uni_data[[i]] <- corrected_annual[[i]][[1]]
    multi_data[[i]] <- corrected_annual[[i]][[2]]
  }
  
  uni_data <- do.call(rbind, uni_data) # Bind back to annual
  multi_data <- do.call(rbind, multi_data) # Bind back to annual
  
  return(list(uni_data, multi_data))
}

corrected_list <- lapply(mdl_list, bias_corr_wrapper)

# Separate datasets
separater <- function(k) {
  lss <- list(obs_data)
  for (i in 1:5) {
    lss[[i+1]] <- corrected_list[[i]][[k]]
  }
  return(lss)
}

uni_list <- separater(1)
multi_list <- separater(2)

saveRDS(list(uni_list,multi_list),'D:/PAPER2/git_paper2_final/qdm_mbc_data.rds',compress = F)
