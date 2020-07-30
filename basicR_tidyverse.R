library(nycflights13)
library(Hmisc)
library(lubridate)
library(tidyverse)

# Data exploration with Hmisc
describe(iris$Sepal.Length)
describe(iris)



## Tidyverse usage

mtcars

## Add/Create columns
# old
mtcars$mpg/mtcars$wt
mtcars$mpg_wt = mtcars$mpg/mtcars$wt

mtcars %>% mutate(mpg_wt = mpg/wt)  # tidyverse way


## Filtering
mtcars[mtcars$mpg > 21, ]

mtcars %>% filter(mpg > 21)


## Sorting
mtcars %>% arrange(-mpg)

## Select columns
mtcars %>% select(mpg, cyl)   # select_if(is.numeric)






## FLIGHTS dataset
f = flights
describe(f)

# There is no Date column so lets create it. HOW WOULD YOU DO THIS?
f = f %>% mutate(date = paste0(month, "-", day, "-", year)) %>%
  select(date, everything(), -year, -month, -day)

# But Date is still a Chr type ...need to convert to date
#library(help="lubridate")
f = f %>% mutate(date = mdy(date))
f

# What is average airtime on each date (by date; organized by date; summarized on date) --> 'group_by' date
f %>% group_by(date)   # how many unique dates would you predict?

f %>% group_by(date) %>%
  summarize(mean(air_time))

# Why am I getting NA values for the Mean?
?mean
describe(flights$air_time)
x = c(1,NA,2)
describe(x)
mean(x)

f %>% group_by(date) %>% # how many unique dates would you predict
  summarize(mean_airtime = mean(air_time, na.rm=T))

# how many flights on each date?
f %>% group_by(date) %>% # how many unique dates would you predict
  summarize(nflights = n())

# plot Num Flights by Date
f %>% group_by(date) %>% # how many unique dates would you predict
  summarize(nflights = n()) %>%
  ggplot(aes(x = date, y = nflights)) +
  geom_line() +
  geom_point()













# SKIP

# Two lines plot
arrtime = f %>% group_by(date) %>% # how many unique dates would you predict
  summarize(mean_arrtime = mean(arr_time, na.rm=T), mean_schedarrtime = mean(sched_arr_time, na.rm=T))

arrtime %>% ggplot(aes(x = date)) + 
  geom_line(aes(y=mean_arrtime, color='firebrick')) + 
  geom_line(aes(y=mean_schedarrtime))

arrtime %>%
  gather(key = "variable", value = "value", -date) %>%
  ggplot(aes(x=date, y=value, color=variable)) +
  geom_line()



