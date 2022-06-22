library(Hmisc)
library(lubridate)
library(tidyverse)

# https://covidtracking.com/data/api

# Obtain State level data
raw = read_csv("http://covidtracking.com/api/v1/states/daily.csv") # unique identifier per row is Date + State
raw   # why is 'date' an integer?  --> look at metadata 
str(raw)

ctdata = raw
ctdata$date = ymd(ctdata$date)
summary(ctdata$date)
describe(ctdata$date)

# Add Rates
ctdata = ctdata %>% mutate(ir = positive/totalTestResults,
                           cfr = death/positive,
                           ifr = death/totalTestResults) 
# describe(ctdata[,c("ir","cfr","ifr")])
# ctdata[is.na(ctdata$ir),]


# Summarize data to obtain US data
us = ctdata %>% group_by(date) %>%
  summarize(positive = sum(positive, na.rm=T),
            death = sum(death, na.rm=T),
            totalTestResults = sum(totalTestResults, na.rm=T)) %>%
  mutate(ir = positive/totalTestResults,
         cfr = death/positive,
         ifr = death/totalTestResults)



# New CASES per day ----
library(help="dplyr")   # find the lead and lag functions
head(us$positive, n=10)
lag(us$positive[1:10])

us %>% 
  mutate(newcases = replace_na(positive - lag(positive),0)) %>%
  ggplot(aes(x=date, y=newcases)) +   
  geom_col()

# by specific State
ctdata %>%
  filter(state == "TX") %>%
  mutate(newcases = replace_na(positive - lead(positive),0)) %>%
  ggplot(aes(x=date, y=newcases)) +
  geom_col()




# RATES ----
us %>% 
  select(date, ir, cfr, ifr) %>%
  filter(date >= "2020-04-05") %>%
  gather(key = "stat", value = "rate", -date) %>%
  ggplot(aes(x=date, y = rate, color = stat)) +
  geom_line() +
  scale_y_continuous(labels = scales::percent)

# by specific State 
s = "PA"
ctdata %>% select(date,state,ir,cfr,ifr) %>%
  filter(state == s, date >= "2020-04-05") %>%
  gather(key = "stat", value = "rate", -date, -state) %>%
  ggplot(aes(x=date, y = rate, color = stat, linetype = stat)) +
  geom_line() +
  scale_y_continuous(labels = scales::percent) +
  labs(title = paste0(s, " CFR, IFR and IR"))

# by all States with facet_wrap
ctdata %>% select(date,state,ir,cfr,ifr) %>%
  filter(date > "2020-04-05") %>% 
  gather(key = "stat", value = "rate", -date, -state) %>%
  ggplot(aes(x=date, y = rate, color = stat)) +
  geom_line() + 
  facet_wrap(~ state, scales= "free_y") 

# by comparing IR between 2 States
ctdata %>%
  filter(date > "2020-04-05", state == "PA" | state == "CA") %>%
  ggplot(aes(x=date, y = ir, color = state)) +
  geom_line() + geom_point() + theme_minimal() +
  scale_y_continuous(labels = scales::percent) +
  labs(title="PA & CA Infection Rate (IR)")

# by comparing CFR between 2 States
ctdata %>%
  filter(date > "2020-04-05", state == "PA" | state == "CA") %>%
  ggplot(aes(x=date, y = cfr, color = state)) +
  geom_line() + geom_point() + theme_minimal() + 
  scale_y_continuous(label = scales::percent) +
  labs(title="PA & CA CFR")










# SKIPPED

## Cumulative US Cases ----
us %>% ggplot(aes(x=date, y=positive)) +   # Change y value to Deaths, totalTestResults
  geom_line() + 
  scale_y_continuous(labels = scales::comma)

# Cumulative US Cases, Death - one graph but multiple geom_line
us %>% ggplot(aes(x=date)) +   
  geom_line(aes(y = positive, color="blue")) + 
  geom_line(aes(y = death, color= "red"))# + 
#geom_line(aes(y = totalTestResults))

# Cumulative US Cases, Death - one graph simplified
us %>%
  select(date, positive, death) %>%
  gather(key = "stat", value = "number", -date) %>%
  ggplot(aes(x=date, y = number, color = stat)) +
  geom_line()

# by specific State 
ctdata %>% select(date, state, positive, death) %>%
  filter(state == "CA") %>%
  gather(key = "stat", value = "number", -date, -state) %>%
  ggplot(aes(x=date, y = number, color = stat)) +
  geom_line()

# by all States with facet_wrap
ctdata %>% select(date,state,positive,death) %>%
  filter(date > "2020-04-05") %>% 
  gather(key = "stat", value = "number", -date, -state) %>%
  ggplot(aes(x=date, y = number, color = stat)) +
  geom_line() + 
  facet_wrap(~ state, scales= "free_y") 

# by comparing2 states
ctdata %>%
  filter(state == "CA" | state=="PA") %>%
  ggplot(aes(x=date, y = positive, color = state)) +
  geom_line() + geom_point() + theme_minimal() + 
  scale_y_continuous(label=scales::comma) +
  labs(title="PA & CA Cummulative COVID19 Cases")







