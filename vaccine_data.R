library(Hmisc)
library(DT)     # datatable
library(tidyverse)  # dplyr, tidyr, ggplot2 and more

# https://github.com/owid/covid-19-data/tree/master/public/data
# https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations

############################
# COUNTRY LEVEL
c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
View(c)

c = c %>% rename(Doses_Given = total_vaccinations,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred)


# DataTable to match Google 'Vaccinations by Location' (on Country level)
unique(c$location)  # 229 locations

vacc_by_loc = c %>% select(location, Doses_Given, Fully_Vaccinated, Perc_Fully_Vaccinated) %>%
  group_by(location) %>% 
  slice_max(date)
unique(vacc_by_loc$location) # expect 229 locations

datatable(vacc_by_loc)



# Vaccine distribution inequity
describe(c$Perc_Fully_Vaccinated)

# if you don't filter for !is.na, you will get many Locations with NA for Perc_Fully_Vaccinated. By doing the filter, you get the latest date with a value for PercFullyVaccinated
cpfv = c %>% select(date, location, Perc_Fully_Vaccinated) %>%
  filter(!is.na(Perc_Fully_Vaccinated)) %>%
  group_by(location) %>%
  slice_max(date) %>%
  ungroup() %>%
  arrange(-Perc_Fully_Vaccinated)
View(cpfv)

num = 25   # want top 10 and bottom 10 countries by percent fully vaccinated

top = cpfv %>% slice(1:num)
top %>% ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()

factor(top$location)

top %>% mutate(location = forcats::fct_reorder(location, Perc_Fully_Vaccinated)) %>%
  ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()

btmtop = cpfv %>% filter(row_number() %in% 1:num | row_number() %in% (n()-num+1) : n() )
btmtop %>% mutate(location = forcats::fct_reorder(location, Perc_Fully_Vaccinated)) %>%
  ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()





############################
# STATE LEVEL
s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
View(s)
describe(s)

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


# Comparison of two states
s1 = "Pennsylvania"
s2 = "South Carolina"
two = long_perc_people %>% filter(location == s1 | location == s2)
two %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=location, linetype=name))


# One state plot (Number vacc'd and Percent vaccinated)
state = "Pennsylvania" # state = "United States"

long_num_people %>% filter(location == state) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma)

long_perc_people %>% filter(location == state) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name))



# All states - number vaccinated 

#   United states throws off y-axis
long_num_people %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) +
  scale_y_continuous(labels = scales::comma) + facet_wrap(~ location)

#   Remove US and change scales free-y
long_num_people %>% filter(location != "United States") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) +
  scale_y_continuous(labels = scales::comma) + facet_wrap(~ location, scales="free_y") 


# All states - perc vaccinated
long_perc_people %>% filter(location != "United States") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) +
  facet_wrap(~ location)










# NOT USED

######################
# Daily vaccinations
s %>% filter(location != "United States") %>%
  select(date, location, daily_vaccinations) %>%
  ggplot(aes(x=date, y=daily_vaccinations)) + geom_line() +
  facet_wrap(~ location, scales="free_y")

s %>% filter(location == state) %>% ggplot(aes(x=date, y=daily_vaccinations)) + geom_line()




