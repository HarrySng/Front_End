climdex_wrapper <- function(p) { # p is always a dataframe with 2 columns - date, pr
  rx1day <- function(p) { # monthly maximum 1 day precipitation
    colnames(p) <- c('date', 'pr')
    pmon <- p %>% group_by(year(date), month(date)) %>% summarise(pr = max(pr))
    return(data.frame(pmon))
  }
  
  r10_20mm <- function(p) { # Annual count of days when PRCP ≥ 10mm and 20mm combined in one function
    colnames(p) <- c('date', 'pr')
    prls <- split(p, year(p$date))
    yr <- c()
    cnt10 <- c()
    cnt20 <- c()
    for(i in 1:length(prls)) {
      yr[i] <- year(prls[[i]]$date)[1]
      cnt10[i] <- length(which(prls[[i]]$pr >= 10))
      cnt20[i] <- length(which(prls[[i]]$pr >= 20))
    }
    return(data.frame('year' = yr, 'r10' = cnt10, 'r20' = cnt20))
  }
  
  sdii <- function(p) { # simple precipitation intensity index
    colnames(p) <- c('date', 'pr')
    prls <- split(p, year(p$date))
    yr <- c()
    res <- c()
    for (i in 1:length(prls)) { # yearly sdii
      wet_days <- which(prls[[i]]$pr >= 1)
      pwet <- prls[[i]][wet_days,]
      res[i] <- sum(pwet$pr)/length(wet_days)
      yr[i] <- year(prls[[i]]$date)[1]
    }
    return(data.frame('year' = yr, 'sdii' = res))
  }
  
  cdd <- function(p) { # Maximum length of dry spell: maximum number of consecutive days with RR < 1mm
    colnames(p) <- c('date', 'pr')
    prls <- split(p, year(p$date))
    cdd_algo <- function(ls) { # ls is data of one year
      pr <- ls$pr # extract a vector of pr
      days <- c() # holder for consecutive day indices
      i = 1 # initial value of iterator
      while (i < length(pr)) {
        if(pr[i] < 1) {
          days <- append(days,i) # append the day index to days if the pr on that day < 1
          i = i + 1 # then check next day
        } else { # otherwise check next day without appending
          i = i + 1
        }
      }
      dsum <- cumsum(c(1, diff(days) - 1)) # cumulative sum
      drle <- rle(dsum) # function for computing lengths of vector
      return(length(days[which(dsum == with(drle, values[which.max(lengths)]))])) # return length of max consecutive dry days
    } 
    res <- data.frame(sapply(prls, cdd_algo))
    return(data.frame('year' = as.numeric(rownames(res)), 'cdd' = res[,1]))
  }
  
  cwd <- function(p) { # Maximum length of wet spell: maximum number of consecutive days with RR ≥ 1mm
    colnames(p) <- c('date', 'pr')
    prls <- split(p, year(p$date))
    cwd_algo <- function(ls) { # ls is data of one year
      pr <- ls$pr # extract a vector of pr
      days <- c() # holder for consecutive day indices
      i = 1 # initial value of iterator
      while (i < length(pr)) {
        if(pr[i] >= 1) {
          days <- append(days,i) # append the day index to days if the pr on that day >= 1
          i = i + 1 # then check next day
        } else { # otherwise check next day without appending
          i = i + 1
        }
      }
      dsum <- cumsum(c(1, diff(days) - 1)) # cumulative sum
      drle <- rle(dsum) # function for computing lengths of vector
      return(length(days[which(dsum == with(drle, values[which.max(lengths)]))])) # return length of max consecutive wet days
    } 
    res <- data.frame(sapply(prls, cwd_algo))
    return(data.frame('year' = as.numeric(rownames(res)), 'cwd' = res[,1]))
  }
  
  # not using rx1day right now
  res <- data.frame(cbind(r10_20mm(p),sdii(p)[,2],cdd(p)[,2],cwd(p)[,2]))
  colnames(res) <- c('year', 'r10', 'r20', 'sdii', 'cdd', 'cwd')
  return(res)
}


