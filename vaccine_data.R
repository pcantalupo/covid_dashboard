library(Hmisc)
library(DT)     # datatable
library(tidyverse)  # dplyr, tidyr, ggplot2 and more

# https://github.com/owid/covid-19-data/tree/master/public/data
# https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations

############################
# COUNTRY LEVEL
c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
str(c)
View(c)

c = c %>% rename(Doses_Given = total_vaccinations,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred)

describe(c$Perc_Fully_Vaccinated)
#c = c %>% mutate(people_fully_vaccinated_per_hundred = replace_na(people_fully_vaccinated_per_hundred, 0))

top25 = c %>% group_by(location) %>% 
  slice(which.max(date)) %>%
  select(location, Perc_Fully_Vaccinated) %>%
  ungroup() %>%
  arrange(-Perc_Fully_Vaccinated) %>% slice(1:25)

top25 %>% ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()

factor(top25$location)

top25 %>%
  mutate(location = forcats::fct_reorder(location, Perc_Fully_Vaccinated)) %>%
  ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()


unique(c$location)  # 229 locations

vacc_by_loc = c %>% group_by(location) %>% 
  slice(which.max(date)) %>%
  select(location, Doses_Given, Fully_Vaccinated, Perc_Fully_Vaccinated)
unique(vacc_by_loc$location) # expect 229 locations

datatable(vacc_by_loc)




############################
# STATE LEVEL
s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
str(s)
View(s)
describe(s)
#d$date = as.Date(d$date, tryFormats = c("%Y-%m-%d"))

s %>% count(location)  # why 65 "states"  # it is a state or federal entity
s %>% count(location) %>% View()


s = s %>% rename(Doses_Given = total_vaccinations,
                 Vaccinated = people_vaccinated,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Vaccinated = people_vaccinated_per_hundred,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred)


long_num_people = s %>%
  select(date, location, Vaccinated, Fully_Vaccinated) %>%
  pivot_longer(-c(date, location)) 

long_perc_people = s %>%
  select(date, location, Perc_Vaccinated, Perc_Fully_Vaccinated) %>%
  pivot_longer(-c(date, location)) 



###########################
# All STATES

# Number people vaccinated #####################

# United states throws off y-axis
long_num_people %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma) + facet_wrap(~ location)

# Remove US and change scales free-y
long_num_people %>% filter(location != "United States") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma) + facet_wrap(~ location, scales="free_y") 


# Perc people vaccinated #####################
long_perc_people %>% filter(location != "United States") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) +
  facet_wrap(~ location)


####################
# PENNSYLVANIA
#pa = s %>% filter(location == "Pennsylvania")
#tail(pa)

#state = "Pennsylvania"
state = "United States"

# number
long_num_people %>% filter(location == state) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma)

# perc
long_perc_people %>% filter(location == state) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name))





######################
# Daily vaccinations
s %>% filter(location != "United States") %>%
  select(date, location, daily_vaccinations) %>%
  ggplot(aes(x=date, y=daily_vaccinations)) + geom_line() +
  facet_wrap(~ location, scales="free_y")

s %>% filter(location == state) %>% ggplot(aes(x=date, y=daily_vaccinations)) + geom_line()


###########################
# Comparison of two states
s1 = "Pennsylvania"
s2 = "Tennessee"
two = long_perc_people %>% filter(location == s1 | location == s2)
two %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=location, linetype=name))





