## cleaning
setwd('C:\\Users\\hsing247\\Desktop\\CEE9535\\Assignment 3')

library(tidyverse)
library(lubridate)

# Function to clean country files
cleaner1 <- function(fname) {
  raw_data <- read_table(fname, skip = 70, col_names = F)
  raw_data <- raw_data[,c(1,5)]
  raw_data <- na.omit(raw_data)
  clean_data <- data.frame(raw_data %>% group_by(X1) %>% summarise(X5 = mean(X5)) %>% filter(X1 >= 1960 & X1 <= 2005))
  colnames(clean_data) <- c('year','tmp')
  return(clean_data)
}

country_files <- list.files(path = '.', pattern = 'TAVG')
tmp_data <- lapply(country_files, cleaner1)

# Function to clean global tmp
cleaner2 <- function(fname) {
  raw_data <- read_delim(fname, col_names = T, delim = ',')
  clean_data <- data.frame(raw_data %>% filter(Source == 'GISTEMP') %>% filter(Year >= 1960 & Year <= 2005))
  clean_data <- clean_data[,c(2,3)]
  colnames(clean_data) <- c('year','tmp')
  clean_data <- clean_data[order(clean_data$year),]
  return(clean_data)
}
tmp_data[[7]] <- cleaner2('annual_csv.txt')

# Function to clean carbon emission data
cleaner3 <- function(fname) {
  raw_data <- read_csv(fname, col_names = T)
  raw_data <- raw_data %>% filter(Year <= 2005)
  clean_data <- data.frame(raw_data)
  return(clean_data)
}
cbn_data <- cleaner3('global_carbon.csv')

# Combine to make 7 datasets

combiner <- function(..) {
  lss <- list()
  for(i in 1:7) {
    lss[[i]] <- data.frame(year = 1960:2005, tmp = tmp_data[[i]]$tmp, cbn = cbn_data$CO2)
  }
  return(lss)
}

final_data <- combiner(..)
rm(list=setdiff(ls(), c('final_data'))) ; gc()

######################################################################################################
library(rethinking)

# Run stan model
stan_wrapper <- function(d) {
  bayes_model <- map2stan(
                        alist(
                          tmp ~ dnorm( mu , 1 ) ,
                          mu <- a + b*cbn ,
                          a ~ dnorm(0,5),
                          b ~ dnorm(0,2)
                        ) ,
                        data=d, chains = 1, iter = 1000, warmup=500)
  return(bayes_model)
}

bayes_mdl_list <- lapply(final_data[1], stan_wrapper)

# Analyse posteriors
post_bayes <- function(m) {
  post <- extract.samples(m)
  intercept <- c(quantile(post$a, 0.025), quantile(post$a, 0.5), quantile(post$a, 0.975))
  slope <- c(quantile(post$b, 0.025), quantile(post$b, 0.5), quantile(post$b, 0.975))
  sdev <- c(quantile(post$sigma, 0.025), quantile(post$sigma, 0.5), quantile(post$sigma, 0.975))
  return(cbind(intercept, slope, sdev))
}

param_list <- lapply(bayes_mdl_list, post_bayes)

library(reshape2)
library(ggsci)
plotter <- function(d, p) { # d is data, p is parameters
  d$tmp_low <- d$cbn*p[1,2] + p[1,1]
  d$tmp_med <- d$cbn*p[2,2] + p[2,1]
  d$tmp_hgh <- d$cbn*p[3,2] + p[3,1]
  
  d <- melt(d,c('year','cbn', 'tmp'))
  
  ggplot(data = d) +
    geom_line(aes(x = cbn, y = value, color = variable)) +
    geom_point(aes(x = cbn, y = tmp), color = 'grey25') +
    scale_color_lancet() + theme_bw()
}

plotter(final_data[[1]], param_list[[1]])


### Extrapolate into future
d <- final_data[[1]]
new_d <- data.frame(year = 2006:2100, cbn = NA) # new df of carbon in future
new_d$cbn <- new_d$year*0.01726 - 30.21919 # extrapolate carbon based on lm(cbn~yr)
new_d$tmp <- new_d$cbn*0.3226857 - 1.0718502 # make new tmp based on bayes (only median here)
mean(new_d$tmp[66:95]) - mean(d$tmp[12:41]) # warming in 2071-2100 compared to 1971-2000
 


new_d$tmpl <- new_d$cbn*0.1582351 - 1.7606299
new_d$tmpu <- new_d$cbn*0.4967020 - 0.3894516

ggplot(melt(new_d,c('year','cbn','tmp'))) +
  geom_line(aes(x = year, y = value, color = variable)) +
  scale_color_lancet() + theme_bw()
