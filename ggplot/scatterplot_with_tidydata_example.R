library(tidyverse)
library(Hmisc)
college <- read_csv('http://672258.youcanlearnit.net/college.csv')   # readr package

describe(college$loan_default_rate)   # what is that NULL?
college$loan_default_rate

college <- college %>%
  mutate(state=as.factor(state), region=as.factor(region),
         highest_degree=as.factor(highest_degree),
         control=as.factor(control), gender=as.factor(gender),
         loan_default_rate=as.numeric(loan_default_rate))

# Simple scatterplot
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg))

# Let's try representing a different dimension.  
# What if we want to differentiate public vs. private schools? Use shape attribute
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, shape=control))

# That's hard to see the difference.  What if we try color instead?
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control))

# What if we want our own colors? ('manual' functions)
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control)) +
  scale_color_manual(values = c('green', 'blue'))
  
# Can also alter point size.  Let's do that to represent the number of students
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads))

# Add some transparency so we can see through those points a bit using alpha value (default = 1)
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1/2)



# Tidy data example
table4a %>%
  ggplot(aes(x = country)) +
  geom_point(aes(y = `1999`)) + 
  geom_point(aes(y = `2000`)) #+
#  geom_point(aes(y = `2001`))  # need to add separate geom_point for every year column


long = table4a %>% pivot_longer(-country, names_to='year', values_to ='cases')
long

long %>% ggplot() +
  geom_point(aes(x=country, y = cases, color=year))


ggsave("plot.png", width = 5, height = 5)
