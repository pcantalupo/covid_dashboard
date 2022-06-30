library(nycflights13)
library(Hmisc)
library(lubridate)
library(tidyverse)

# Data exploration with Hmisc
describe(iris$Sepal.Length)
describe(iris)


# Forcats fct_reorder example
iris$Species
boxplot(Sepal.Width ~ Species, data = iris)
boxplot(Sepal.Width ~ fct_reorder(Species, Sepal.Width), data = iris)



## Tidyverse usage

## FLIGHTS dataset
?flights
f = flights
describe(f)

## Add/Create columns - base R
# let's add a speed column
f$distance / f$air_time * 60   # miles per hour  # Notice NA values
f$mph = f$distance/f$air_time * 60

## Mutate - tidyverse way
f = mutate(f, mph = distance/air_time * 60)

## Select columns
f %>% select(year, month, day, carrier, mph)
f %>% select_if(is.character)  # is.numeric, and more
f %>% select(-carrier, -tailnum)

## Filtering
f[which(f$mph > 300), ]         # base R   # Remember which()!
f %>% filter(mph > 300)         # tidyverse doesn't need which()

## Sorting
f %>% arrange(-mph)

## Rename columns
f %>% rename(miles_per_hour = mph)

## Summarizing
f %>% summarize(median(distance))


# There is no Date column so lets create it. HOW WOULD YOU DO THIS?
f = f %>% mutate(date = paste0(month, "-", day, "-", year)) %>%
  select(date, everything())

# But Date is still a Chr type ...need to convert to date
#library(help="lubridate")
f = f %>% mutate(date = mdy(date))
f

# select all flights on January 1st with
filter(flights, month == 1, day == 1)   # note: use == not =  (also !=)
#  or 
filter(flights, month == 1 & day == 1)

# flights in November or December
filter(flights, month == 11 | month == 12)  # filter(flights, month %in% c(11, 12))


# How many flights on each date?  (by date; organized by date; summarized on date) --> 'group_by' date
# how many unique dates would you predict?
f %>% group_by(date) %>% 
  summarize(nflights = n())

f %>% count(date, name = "nflights")  # count is much easier!
f %>% count(date, sort=TRUE)

# What is average airtime on each date
f %>% group_by(date) %>%
  summarize(mean(air_time))

# Why am I getting NA values for the Mean?
?mean
describe(flights$air_time)
x = c(1,NA,2)
describe(x)
mean(x)
is.na(x)

f %>% group_by(date) %>% 
  summarize(mean_airtime = mean(air_time, na.rm=TRUE))


# What is the last date for each carrier?
f %>% count(carrier)
f %>% group_by(carrier) %>% slice_max(date) %>% select(date, carrier, flight)  # ?slice_max
f %>% group_by(carrier) %>% slice_max(date, with_ties=FALSE) %>% select(date, carrier)


# Tidy data introduction - why needed?
table4a
table4a %>% pivot_longer(-country, names_to='year', values_to ='cases')










# NOT USED
arrtime = f %>% group_by(date) %>%
  summarize(mean_arrtime = mean(arr_time, na.rm=T),
            mean_schedarrtime = mean(sched_arr_time, na.rm=T))

arrtime %>% ggplot(aes(x = date)) + 
  geom_line(aes(y=mean_arrtime), color = 'red') + 
  geom_line(aes(y=mean_schedarrtime), color = 'blue')
# geom_line(a) +   # would have to keep adding geom_lines for every column of data
# geom_line(b)

arrtime %>%
  pivot_longer(-date, names_to = "arrtime", values_to = "time") %>%
  ggplot(aes(x=date, y=time, color=arrtime)) +
  geom_line()






