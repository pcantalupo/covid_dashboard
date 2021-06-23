library(Hmisc)
library(tidyverse)  # dplyr, tidyr, ggplot2 and more

# https://github.com/owid/covid-19-data/tree/master/public/data
# https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations

c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
str(c)
View(c)



s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
str(s)
View(s)
describe(s)
#d$date = as.Date(d$date, tryFormats = c("%Y-%m-%d"))


s %>% count(location)  # why 65 "states"
s %>% count(location) %>% View()

s %>% select(date, location, people_vaccinated, people_fully_vaccinated) %>% pivot_longer(-c(date, location)) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma) + facet_wrap(~ location)


s %>% filter(location != "United States") %>% select(date, location, people_vaccinated, people_fully_vaccinated) %>% pivot_longer(-c(date, location)) %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma) + facet_wrap(~ location)




pa = s %>% filter(location == "Pennsylvania")
tail(pa)
pa %>% select(date, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred) %>%
  pivot_longer(-date, names_to="variable") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=variable))

pa %>% select(date, people_vaccinated, people_fully_vaccinated) %>% pivot_longer(-date, names_to="variable") %>%
  ggplot(aes(x=date, y=value)) + geom_line(aes(color=variable)) + scale_y_continuous(labels = scales::comma)









