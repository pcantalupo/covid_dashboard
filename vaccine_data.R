library(Hmisc)
library(tidyverse)  # dplyr, tidyr, ggplot2 and more

# https://github.com/owid/covid-19-data/tree/master/public/data
# https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations

############################
# COUNTRY LEVEL
c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
str(c)
View(c)


describe(c$people_fully_vaccinated_per_hundred)
#c = c %>% mutate(people_fully_vaccinated_per_hundred = replace_na(people_fully_vaccinated_per_hundred, 0))

top25 = c %>% group_by(location) %>% 
  slice(which.max(date)) %>%
  select(location, people_fully_vaccinated_per_hundred) %>% ungroup() %>%
  arrange(-people_fully_vaccinated_per_hundred) %>% slice(1:25)

top25 %>% ggplot(aes(x=location, y=people_fully_vaccinated_per_hundred)) +
  geom_col() +
  coord_flip()

factor(top25$location)

top25 %>%
  mutate(location = forcats::fct_reorder(location, people_fully_vaccinated_per_hundred)) %>%
  ggplot(aes(x=location, y=people_fully_vaccinated_per_hundred)) +
  geom_col() +
  coord_flip()



############################
# STATE LEVEL
s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
str(s)
View(s)
describe(s)
#d$date = as.Date(d$date, tryFormats = c("%Y-%m-%d"))

s %>% count(location)  # why 65 "states"  # it is a state or federal entity
s %>% count(location) %>% View()

###########################
# Number people vaccinated
# All STATES
s %>% select(date, location, people_vaccinated, people_fully_vaccinated) %>% pivot_longer(-c(date, location)) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma) + facet_wrap(~ location)

s %>% filter(location != "United States") %>% select(date, location, people_vaccinated, people_fully_vaccinated) %>% pivot_longer(-c(date, location)) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma) + facet_wrap(~ location, scales="free_y") 

s %>% filter(location != "United States") %>%
  select(date, location, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred) %>%
  pivot_longer(-c(date, location), names_to="variable") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=variable)) +
  facet_wrap(~ location)

# PENNSYLVANIA
pa = s %>% filter(location == "Pennsylvania")
tail(pa)
pa %>% select(date, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred) %>%
  pivot_longer(-date, names_to="variable") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=variable))

pa %>% select(date, people_vaccinated, people_fully_vaccinated) %>% pivot_longer(-date, names_to="variable") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=variable)) + scale_y_continuous(labels = scales::comma)



######################
# Daily vaccinations
s %>% filter(location != "United States") %>%
  select(date, location, daily_vaccinations) %>%
  ggplot(aes(x=date, y=daily_vaccinations)) + geom_line() +
  facet_wrap(~ location, scales="free_y")

pa %>% ggplot(aes(x=date, y=daily_vaccinations)) + geom_line()


###########################
# Comparison of two states
two = s %>% filter(location == "Pennsylvania" | location == "Tennessee")
two %>% select(date, location, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred) %>%
  pivot_longer(-c(date, location), names_to="variable") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=location, linetype=variable))





