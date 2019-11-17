######################################################################################
#                       Automated Raven Hydrological Model Run                       #
#                               Created By: Harry Singh                              #
#                                 Date: July-19-2019                                 #
######################################################################################

######################## Pre-Requisite Block ##########################
# Raven model directory setup
setwd('D:/PAPER2/')
wshed_name <- 'Kootenay_Lake_ws' # Name of watershed
raven_dir <- 'D:/PAPER2/Raven_biv/' # Parent directory
raven_in_dir <- 'D:/PAPER2/Raven_biv/dt/' # Data directory where input file will be created
raven_out_dir <- 'D:/PAPER2/Raven_biv/res/' # Output directory where results will be created

# Parent input file - Named "data.tb0"
# There needs to be a parent input file in the raven_dir directory containing
# the top 25 lines of the raven input format. This file will be copied to input
# directory in each run and input values of tmp and pr will be appended to run the model.

######################## Pre-Requisite Block ends here ################


######################## Helper Function Block ########################
# Command batch file
# To run Raven from R, a command batch file will be created in the directory

batch_string <- paste(raven_dir, 'Raven.exe ', raven_dir, wshed_name, ' -o ',raven_out_dir, sep="")
write(batch_string, file = paste(raven_dir,'rvn.cmd',sep=""), append = F) # Write the data to the input file

######################## Helper Function Block ends here ###############


######################## Primary function Block ########################
run_raven <- function(input_data) {
  # Input data is a matrix with two rows (tmp, pr)
  data_to_write <- paste(input_data[,1],' ',input_data[,2]) # Convert data to space separated character format
  file.copy(from = paste(raven_dir,'data.tb0',sep=""), to = raven_in_dir, overwrite = T) # Copy the parent input file to data directory
  write(data_to_write, file = paste(raven_in_dir,'data.tb0',sep=""), append = T) # Write the data to the input file
  system(paste(raven_dir,'rvn.cmd',sep="")) # Run the raven hydrological model from the batch file created earlier
  
  raw_data <- read.table(list.files(path = raven_out_dir, pattern = 'Hydro', full.names = T), 
                         header = F, skip = 22, sep=" ") # Read the raw hydrograph data
  raw_data <- raw_data[,-1]
  
  # Create final dataframe with input and output to return
  res_df <- data.frame(
    'tmp' = input_data[,1],
    'pr' = input_data[,2],
    'sim_qq' = raw_data$V3
  )
  return(res_df)
}

synthetic <- function(n) {
  dist1 <- c(8,5)
  dist2 <- c(0.22,0.11)
  prm <- c(3.73, 2.84)
  seed <- 44
  set.seed(seed)
  mv1 <- mvdc(claytonCopula(prm[1]), c('norm','weibull'), list(list(mean = dist1[1], sd = dist1[2]), list(shape = dist2[1], rate = dist2[2])))
  set.seed(seed)
  u <- rCopula(n, mv1@copula)
  u[,1] <- qnorm(u[,1], mean = dist1[1], sd = dist1[2])
  u[,2] <- qgamma(u[,2], shape = dist2[1], rate = dist2[2])
  d1 <- u
  
  set.seed(seed)
  #mv2 <- mvdc(joeCopula(prm[2]), c('norm','weibull'), list(list(mean = dist1[1], sd = dist1[2]), list(shape = dist2[1], rate = dist2[2])))
  mv2 <- mvdc(gumbelCopula(prm[2]), c('norm','weibull'), list(list(mean = dist1[1], sd = dist1[2]), list(shape = dist2[1], rate = dist2[2])))
  set.seed(seed)
  u <- rCopula(n, mv2@copula)
  u[,1] <- qnorm(u[,1], mean = dist1[1], sd = dist1[2])
  u[,2] <- qgamma(u[,2], shape = dist2[1], rate = dist2[2])
  d2 <- u
  
  return(list(d1,d2))
}

######################## Primary function Block ends here ##############


######################## Interactive Block #############################

data_list <- synthetic(11323)
# This is a list of 7 datasets (1 Guage, 1 AHCCD, 5 gridded products)
res_list <- lapply(data_list, run_raven) # Run the raven model over each dataset

