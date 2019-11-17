# Scripting best practices
# Make a new project in a new directory when starting new work
# Create atleast two folders inside your project. One for your raw data and other for your results
# Extensive commenting. Over explain, if necessary. You will thank yourself when you read the script one month later.

# Test_Project - Write project title ##
# 2018-10-02 - Date

setwd('D:/tutorial/') # This will be the directory where R will read/write data

# Now start

### R and RStudio
	# Rstudio is a user-interface to R langauge to make your life easier.

### User interface - There are 4 panles
  # This (top-left) is where you write the script
  # If you execute a line of the script, it will run in the window below (CONSOLE) and the output will also be printed there
  # On the top right is the environment where all variables will be saved
  # Bottom right has all the plots, help etc.
  # You can run a command directly in the console as well (But it will not be saved anywhere and you will lose what you wrote)

### Interpreted language
  # Commands are executed line by line. As opposed to something like C++ where the whole program is compiled and then executed
  # Open source - There are some base functionalities but a major chunk is code added by other users called "Packages"
  
### Everything in R happens inside the RAM of the PC. So, your RAM limits the amount of data you can work with (although there are advanced workarounds)
### Not to worry - For example a table with a million rows and 2 columns only takes up about 700MB of space

### Basic data types - Integer, Float, String, Boolean
5 , 5.0 , 'Harry' , TRUE
# Not very important to you, but note that R will always save a number as float even if it has no decimal points. To save it as integer, you have to specify as.integer(5)
class(5)

### Generating sequences
  1:5 # Generate a sequence by increments of 1
  seq(from = 1,to = 100, by = 10) # Generate sequence with custom increment
  seq(1,100,10)
  rep('a',3)
  rep(T,3)

### Variables 
  x <- 5    # You can also use = sign also to assign values to a variables
  y <- 'a'
  z <- T
  x <- 9 # This will overwrite previous value
  
### Data containers
# Vectors - A one dimension collection of ONLY ONE datatype
  c(3, 4, 5, 6, 1, 2, 9) # Vector of integers
  c(3.0, 4.0, 5.0, 6.0, 1.0, 2.0, 9.0) # Vector of floats
  c("Harry", "Potter") # Vector of strings
  c(T, F, F, T, T) # Vector of booleans
  vec <- c(1,2,3,4,5) # Assigning a vector to a variable
  # Think about these cases:
  c(3, "a")
  c(5)
  
# Matrix - Two dimensional (Rows x Columns) collection of ONLY ONE datatype
  matrix(1:9, nrow = 3, ncol = 3) # Arrange the numbers 1 to 9, in 3 rows and 3 columns
  matrix(c('a','b','c'), nrow = 3, ncol = 1)
  matrix(T, nrow = 5, ncol = 2) # If you provide only one value, it will be repeated in all rows, columns
  m <- matrix(1:9, nrow = 3, ncol = 3) # Assign matrix to a variable
  
# Dataframes - Two dimensional collection of multiple datatypes (but only one datatype per column)
  df <- data.frame(id = 1:9, name = letters[1:9]) # Create a table where the first column is numbers and second is strings. id and name are column names
  df2 <- data.frame(m) # Convert a matrix to a dataframe.
  # You can convert a dataframe to a matrix with "as.matrix" function. But if your dataframe has mixed datatype columns, matrix will convert them to all characters
  # You will be working with dataframes the most
  
# List - A collection of all the above data types
  # You can put anything into a list
  lss <- list(vec, m, x, y, z) # NOTE - the m inside this list is separate from the m in your environment now
  lss2 <- list(lss, lss) # Lists inside list
  
  
### Fetching data from objects
  # Indexing is the most fundamental aspect in all programming languages.
  # All indexing is done using square brackets
  vec <- 21:30 # Create a vector
  vec[1] # See first element of the vector 
  vec[10] # Last element
  vec[11] # What happens now
  vec[4:7] # Fourth to seventh element
  vec[c(1,3,5,7)] # Only see these specific elements
  ind_small <- which(vec < 5) # which is a function that fetches index of values from a data container based on a given condition

  # Two dimensional objects are always indexed as [R , C]
  m <- matrix(21:29, nrow=3, ncol=3)
  m[1,1] # Fetch element at 1st row and 1st column
  m[2:3,2] # 2nd and 4rd row, 2nd column
  m[1,2:3] # 1st row, 2nd and 3rd column
  m[4,2] # What happens?
  
  m[,1] # Fetch ALL rows from the first column
  m[3,] # Fetch the third row and ALL columns
  sub_m <- m[,2:3] # Fetch all rows, 2nd and 3rd column - This is a matrix in itself because its 2 dimensional
  
  # Dataframe indexing is similar to matrix
  df <- data.frame(id = 1:9, name = letters[1:9])
  df[1,1]
  df[1:5,2]
  df[,1]
  df[2,]
  sub_df <- df[1:2,1:2]
  # One extra element - Dataframe have column names. So you can fetch them by the name itself
  df$id # The dollar sign is used to access columns inside a dataframe by their respective names
  df$name
  
  # Lists
  lss[[1]] # 1st element
  lss[[2]]
  # Now notice that the second element of the list is a matrix. So you can subset it exactly as you subset a matrix
  lss[[2]][,2:3]
  lss2[[1]][[2]][,2:3]  # What is happening here?
  # lss2[[1]] is a list itself
    # The second element of that nested list is a matrix, so lss2[[1]][[2]] is a matrix
    # Then we subset that matrix
  	# Turtles all the way down ...
  
### Functions
  # Anything that performs an operation - always used with brackets
  list() # a function that creates a list
  matrix() # a function that creates a matrix
  sum() # Will sum numbers
  5+6
  sum(5+6)
  sum(5,6)
  sum(1,2,3,4,5)
  sum(1:5)  
  sum(m) # Sum of a matrix
  sum(df) # Why doesnt this work
  sum(df$id) # But this does
  
### Loops
  # Wnat if you want to do something repetitively?
  for (i in 1:10) {
    print('Do something repetitively here')
  }
  
### Loading data in R
  # R can load pretty much any data type - ASCII, csv, excel etc
  # csv is most common
  
  my_data <- read.csv("df.csv") # This will automatically load as a dataframe
  
##########################################################################################
# TIDYVERSE (The Tidy Universe)
# A collection of packages that make R very easy and intuitive to use
# Makes plotting very easy and aesthetically appealing

packages <- c('tidyverse','data.table','nycflights13','gapminder','Lahman', 'RColorBrewer','lubridate') ## Add all package names here
lapply(packages, library, character.only = TRUE)

#################### EXPLORING/MODIFYING YOUR DATA #################### 

# Explore the data
head(my_data) # See top six rows along with column names
tail(my_data) # See bottom six rows along with column names 
str(my_data) # Details, datatype of every column in dataframe
dim(my_data) # See dimensions of data
# ssn column here stand for season (1-winter, 2-spring, 3-summer, 4-fall)

# dplyr package (inside tidyverse) has 6 main functions
# it has 6 main functions

#1. filter()
spring_data <- filter(my_data, ssn == 2) # Filter only spring data
summer_hot <- filter(my_data, ssn == 3, tmp > 25) # Filter summer, where tmp > 25
qt95 <- quantile(df$tmp, 0.95)
tmp_95 <- filter(my_data, tmp > qt95)

#2. arrange()
arrange(my_data, tmp) # sort the dataframe by tmp column
arrange(my_data, desc(tmp)) # for descending

#3. select()
select(my_data, Date, pr) # Select these columns from the dataframe
select(my_data, tmp:ssn) # Select all columns from A to B inclusive
select(my_data, -(tmp:ssn)) # Select all columns except A to B inclusive
rename(my_data, season = ssn) # Rename any column

#4. mutate() - adds new columns which are functions of existing columns

x <- data.frame('maxt' = 11:20, mint = 1:10)
mutate(x,
       tmpK = (maxt + mint)/2) ## Create a new column in your dataframe. Remember to save it in a variable

transmute(x,
          avgt = (maxt + mint)/2, ## Create a new column but delete old columns
          new_col = 41:50)  ## Can add a totally new column if you want

## The PIPE operator '%>%'. Read it as 'then'

my_data %>% # Go inside this dataframe, THEN
  filter(ssn == 3) %>% # Filter season 3, THEN
  filter(tmp > 25) %>% # Filter all days with tmp > 25, THEN
  arrange(pr) %>% # Sort whatever is remaining by pr
  mutate(tmpK = tmp + 273.15) # Add a new column that has tmp in Kelvin

# You can keep adding pipe operators to do as many operations as you want


### Using GGPLOT ###
# ggplot only accepts dataframes as inputs. No other datatype. (not a big deal! You can convert almost every data type into a dataframe)

head(mpg) # mpg is a random dataset already loaded in the tidyverse package for practice
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) #ggplot creates a blank coordinate system. All functions after it are layers added on top of this coord system.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class)) #Coloring class of vehicles in color to differentiate. ggplot adds legend etc automatically for color

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class)) #Can use size instead of color but its not very intuitive here

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class)) #alpha determines transparency. Bigger value - darker. Smaller value - lighter.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class)) #this will change shape of each class. Doesnt work if you have >6 groups as in this case. Last group goes blank.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class, shape=class)) #can combine two aesthetics

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue") #If not doing classification, only doing manual color/shape etc, use the keyword OUTSIDE aesthetic


#################### WORKING WITH DATES #################### 
#package used is 'lubridate'
library(lubridate)

## make some example date data
dts <- seq(from = as.Date('2017-01-01'), to = as.Date('2017-12-31'), by=1) # Creating a sequence of dates
year(dts) #Extract year from date
month(dts) #Extract month from date
mday(dts) #Extract day of month
yday(dts) #Extract day of year

## Suppose you have three separate columns of year, month and date
year <- year(dts)
month <- month(dts)
day <- mday(dts)
# You can use the following function to merge them into a date column
date_col <- make_date(year, month, day)

#timespans
h_age <- today() - ymd(19911209) ## Gives number of days between today and 
as.duration(h_age) ## Convert number of days to years

# This is very helpful in subsetting your data
# See the previous dataframe my_data now, which had a date column
my_data %>% # Go inside dataframe, THEN
  filter(year(Date) == 2019) %>% # Filter data of the year 2019, THEN
  filter(month(Date) == 9) %>% # Filter data of the month September, THEN
  filter(day(Date) == 25) # Filter data of the date 25th

# You may combine them
my_data %>%
  filter(year(Date) == 2019 & month(Date) == 9 & day(Date) == 25)

# You can also combine pipes with ggplot
my_data %>% 
  filter(year(Date) == 2019) %>%
  ggplot() +
  geom_point(aes(x = tmp, y = pr, color = factor(ssn)))




################################################
# Open website "rstudio.cloud"               ###
# Create account with google/facebook        ###
# Start new project                          ###
# Run these commands                         ###
install.packages('devtools')				 ###
library(devtools)                            ###
install_github("rmcelreath/rethinking")      ### 
library(rethinking)                          ###  
################################################

#################### EXTRA COMMANDS - READ THROUGH THEM. THEY WILL BE VERY USEFUL IN YOUR ASSIGNMENTS #################### 

#adding labels
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) + # Adds a smooth trendline to data
  labs(title = "Fuel efficiency generally decreases with engine size" ) # Add title to plot


#using subtitles and captions
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov")


#using labs() for axis and legend
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

#change colors
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  scale_color_brewer(palette = "Set2") #select a different color palette

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv, shape = drv)) + #using shape and color pallette together for even better graphs
  scale_color_brewer(palette = "Dark2")
#see package RColorBrewer

presidential %>%
  mutate(id = 33 + row_number()) %>%
  ggplot(aes(start, id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_colour_manual(
    values = c(Republican = "red", Democratic = "blue") #define your own colors
  )

#Using themes
#Customize non-data elements with themes
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_bw()
#By default ggplot has 8 themes. refer to package "ggthemes" for more