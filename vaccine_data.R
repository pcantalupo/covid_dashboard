library(Hmisc)
library(DT)     # datatable
library(zoo)    # interpolation of missing values
library(tidyverse)  # dplyr, tidyr, ggplot2 and more

# https://github.com/owid/covid-19-data/tree/master/public/data
# https://github.com/owid/covid-19-data/tree/master/public/data/vaccinations

# COUNTRY LEVEL ################
c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
View(c)

c = c |> rename(Doses_Given = total_vaccinations,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred,
                 Boosted = total_boosters,
                 Perc_Boosted = total_boosters_per_hundred)


# DataTable ###############
unique(c$location)  # 235 locations

vacc_by_loc = c |> select(date, location, Doses_Given, Fully_Vaccinated, Perc_Fully_Vaccinated, Boosted, Perc_Boosted) |>
  group_by(location) |> 
  slice_max(date)
#  select(-date) |>
unique(vacc_by_loc$location) # expect 235 locations

datatable(vacc_by_loc)



# Country vaccine inequality ##################
describe(c$Perc_Fully_Vaccinated)

# if you don't filter for !is.na, you will get many Locations with NA for Perc_Fully_Vaccinated. By doing the filter, you get the latest date with a value for PercFullyVaccinated. Some countries (i.e. Switzerland) have NA for all dates.
cpfv = c |> select(date, location, Perc_Fully_Vaccinated) |>
  filter(!is.na(Perc_Fully_Vaccinated)) |>
  group_by(location) |>
  slice_max(date) |>
  arrange(-Perc_Fully_Vaccinated) |>
  ungroup()
View(cpfv)

num = 25   # want top 'num' and bottom 'num' countries by percent fully vaccinated

btmtop = cpfv |> filter(row_number() %in% 1:num | row_number() %in% (n()-num+1) : n() )
btmtop |> 
  ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()

factor(btmtop$location)

btmtop |> mutate(location = forcats::fct_reorder(location, Perc_Fully_Vaccinated)) |>
  ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
  geom_col() +
  coord_flip()






# STATE LEVEL ##############
s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
View(s)
describe(s)  # missing data!  We will get rid of it below

s |> count(location)  # why 65 "states"  # it is a state or federal entity

s = s |> rename(Doses_Given = total_vaccinations,
                 Vaccinated = people_vaccinated,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Vaccinated = people_vaccinated_per_hundred,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred,
                 Boosted = total_boosters,
                 Perc_Boosted = total_boosters_per_hundred)

# Create tibble with Number vaccinated
long_num_people = s |>
  select(date, location, Vaccinated, Fully_Vaccinated, Boosted) |>
  pivot_longer(-c(date, location), names_to="vaxType", values_to = "number")
# we see gaps in the lines due to missing data
long_num_people |> filter(location == "Pennsylvania") |>
  ggplot() + geom_line(aes(x=date, y=number, color=vaxType))

# get rid of NAs using zoo library to interpolate values
long_num_people = s |>
  select(date, location, Vaccinated, Fully_Vaccinated, Boosted) |>
  group_by(location) |> 
  mutate(Vaccinated = na.approx(Vaccinated, na.rm=FALSE),
         Fully_Vaccinated = na.approx(Fully_Vaccinated, na.rm=FALSE),
         Boosted = na.approx(Boosted, na.rm = FALSE)) |>
  pivot_longer(-c(date, location), names_to="vaxType", values_to = "number") 

# Create tibble with Percentage vaccinated
#   get rid of NAs using zoo library to interpolate values
long_perc_people = s |>
  select(date, location, Perc_Vaccinated, Perc_Fully_Vaccinated, Perc_Boosted) |>
  group_by(location) |> 
  mutate(Perc_Vaccinated = na.approx(Perc_Vaccinated, na.rm=FALSE),
         Perc_Fully_Vaccinated = na.approx(Perc_Fully_Vaccinated, na.rm=FALSE),
         Perc_Boosted = na.approx(Perc_Boosted, na.rm = FALSE)) |>
  pivot_longer(-c(date, location), names_to = "vaxType", values_to = "percentage") 


# Comparison of two states (use Percentages) ################
s1 = "Pennsylvania"
s2 = "South Carolina"
#s2 = "Alabama"
two = long_perc_people |> filter(location == s1 | location == s2) |>
  mutate(location = factor(location, levels=c(s1, s2)))

two |>
  ggplot(aes(x=date, y=percentage)) + geom_line(aes(color=location, linetype=vaxType))
# do you like the linetype?  let's create facets instead
two |>
  ggplot(aes(x=date, y=percentage)) + geom_line(aes(color=location)) +
  facet_wrap(~vaxType) +
  theme(axis.text.x = element_text(angle = 90))  # google search: 'ggplot rotate xaxis labels'



# One state plot or US plot (use number Vaccinated) ###############
state = "Pennsylvania"
#state = "United States"

long_num_people |> filter(location == state) |>
  ggplot(aes(x=date, y=number)) + geom_line(aes(color=vaxType)) + scale_y_continuous(labels = scales::comma)
# long_perc_people |> filter(location == state) |>
#   ggplot(aes(x=date, y=percentage)) + geom_line(aes(color=vaxType))



# All states plot ########################
# Number vaccinated
#   United states throws off y-axis
long_num_people |>
  ggplot(aes(x=date, y=number)) + geom_line(aes(color=vaxType)) +
  scale_y_continuous(labels = scales::comma) + facet_wrap(~ location)

#   Remove US and change scales free-y
long_num_people |> filter(location != "United States") |>
  ggplot(aes(x=date, y=number)) + geom_line(aes(color=vaxType)) +
  scale_y_continuous(labels = scales::comma) + facet_wrap(~ location, scales="free_y") 

# Perc vaccinated
long_perc_people |> filter(location != "United States") |>
  ggplot(aes(x=date, y=percentage)) + geom_line(aes(color=vaxType)) +
  facet_wrap(~ location)



sessionInfo()


