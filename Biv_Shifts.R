# 3 year slices across all 50 runs. Extract mean of max temperature and accumulated precipitation

# Load libraries
library(tidyverse)
library(ggsci)
library(reshape2)
library(viridis)
library(lubridate)
library(copula)
library(VineCopula)
library(doParallel)
library(rgdal)
library(ggthemes)
library(fitdistrplus)
library(ggpubr)
library(Metrics)

############# Interactive Block Block #####################
zone <- 13 # Define zone
mns <- c(6,7,8)
scenario <- 'hw' # hd - Hot and Dry. hw - Hot and Wet. cd - Cold and wet
data_list <- unlist(lapply(list.files(path = './rds_obj/gmean/',full.names = T),readRDS),recursive = F) # Read data
dt <- readRDS('./rds_obj/RCM_Dates.rds') # Dates
fn <- read.csv('Copulas.csv', header = T, stringsAsFactors = F) # copula function names

# Run functions
zone_ls <- lapply(1:length(data_list), function(i) return(data_list[[i]][[zone]])) # Extract data of zone
ext_ls <- lapply(zone_ls, calc_anamoly) # List of 50 dataframes, with yearly extremes in each (150 rows)
pooled_list <- pool_extremes(ext_ls)
returns_list <- sapply(pooled_list, calc_returns)
plot(returns_list,type = 'l')
returns_plotter1(returns_list)
returns_plotter2(returns_list)
############# Interactive Block end here #####################


############# Helper functions #####################
altf <- possibly(fitdist, otherwise = data.frame("loglik" = -999999)) # catch errors

fitp <- function(p) { # pcp fitting function
  f1 <- altf(p, 'gamma',lower = c(0, 0))$loglik
  f2 <- altf(p, 'weibull',lower = c(0, 0))$loglik
  f3 <- altf(p, 'lnorm',lower = c(0, 0))$loglik
  f4 <- altf(p, 'norm',lower = c(0, 0))$loglik
  ff <- max(f1,f2,f3,f4)
  if (ff == f1) {pm <- fitdist(p, 'gamma',lower = c(0, 0))
  } else if (ff == f2) {pm <- fitdist(p, 'weibull',lower = c(0, 0))
  } else if (ff == f3) {pm <- fitdist(p, 'lnorm',lower = c(0, 0))
  } else if (ff == f4) {pm <- fitdist(p, 'norm')}
  return(pm)
}

copfit <- function(t_,p_,f,c) { # fitting function
  mv <- mvdc(match.fun(f)(param = c(c$par)), c(t_$distname,p_$distname), 
             list(list(t_[["estimate"]][[1]],t_[["estimate"]][[2]]), 
                  list(p_[["estimate"]][[1]],p_[["estimate"]][[2]])))
  return(mv)
}


############# Primary Function Block #####################
calc_anamoly <- function(d) {
  
  # mean of base period
  p_mean_base <- as.numeric(data.frame(d %>% mutate(tmp = ((tmn+tmx)/2)-273.15, pr = pr*86400,tmn = NULL, date = dt, tmx = NULL) 
                  %>% filter(year(date) <= 2010) %>% filter(month(date) %in% mns)) %>% summarise(pr = mean(pr)))
  
  # Now mutate and aggregate whole data and extract average tmp of season and max anamoly of season
  d <- data.frame(d %>% mutate(tmp = ((tmn+tmx)/2)-273.15, pr = pr*86400,tmn = NULL, date = dt, tmx = NULL) 
                  %>% filter(year(date) > 1950) %>% filter(month(date) %in% mns) %>%
                  mutate(pr = pr - p_mean_base) %>% mutate(pr = -pr) %>% # Calc anamoly then change sign
                  group_by(year(date)) %>% summarise(tmp = mean(tmp), pr = max(pr))) 
  colnames(d) <- c('year','tmp','pr')
  return(d)
}

pool_extremes <- function(ext_ls) {
  lss <- list()
  for(j in seq(1,148,3)) {
    ls <- list()
    for (i in 1:length(ext_ls)) {
      ls[[length(ls)+1]] <- ext_ls[[i]][j:(j+2),2:3]
    }
    lss[[length(lss)+1]] <- data.frame(do.call(rbind,ls))
  }
  return(lss)
} 


calc_returns <- function(d) { # d is a list of 50 dataframes
  cop <- BiCopSelect(pobs(d$tmp), pobs(d$pr), familyset = c(3:6), 
                     rotations = T, selectioncrit = 'AIC', method = 'mle')
  csum <- cop[["familyname"]]
  fam <- data.frame('Copula' = csum) # frame it
  fam <- left_join(fam, fn, by = 'Copula') # join with cop list to match.fun function name later
  tmarg <- fitdist(d$tmp, 'norm')
  pmarg <- fitp(d$pr)
  m <- copfit(tmarg,pmarg,fam[1,2],cop) # bivariate distribution by joining copula and marginals
  #smp <- rMvdc(1000,m)
  # Return level calculation now
  
  if(pmarg$distname == 'gamma') {pfun <- 'pgamma'
  } else if (pmarg$distname == 'weibull') {pfun <- 'pweibull'
  } else if (pmarg$distname == 'lnorm') {pfun <- 'plnorm'
  }else if (pmarg$distname == 'norm') {pfun <- 'pnorm'}
  
  # Extreme heat and low precipitation fetched from base_event
  # Generate univariate density
  t_prob <- pnorm(base_event[1], m@paramMargins[[1]][1][[1]], m@paramMargins[[1]][2][[1]])
  p_prob <- eval(parse(text = pfun))(base_event[2], m@paramMargins[[2]][1][[1]], m@paramMargins[[2]][2][[1]])
  
  # Univariate return levels
  tret <- round(1/(1-t_prob)*1) 
  pret <- round(1/(1-p_prob)*1) # 1 is Return Level here (annual)
  
  # Now find bivariate density of t and p samples
  m_prob <- pMvdc(base_event, m)
  
  # Bivariate return levels
  #biret <- round(1/(1-t_prob-p_prob+m_prob)*1)
  biret <- 1/(1-m_prob)*1
  return(biret)
}


############# Primary Function Block ends here #####################

