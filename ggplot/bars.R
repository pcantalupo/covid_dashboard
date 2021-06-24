library(tidyverse)
college <- read_csv('http://672258.youcanlearnit.net/college.csv')
college <- college %>%
  mutate(state=as.factor(state), region=as.factor(region),
         highest_degree=as.factor(highest_degree),
         control=as.factor(control), gender=as.factor(gender),
         loan_default_rate=as.numeric(loan_default_rate))

# How many schools are in each region?
# This calls for a bar graph!
ggplot(data=college) +
  geom_bar(mapping=aes(x=region))

# Break it out by public vs. private
ggplot(data=college) +
  geom_bar(mapping=aes(x=region, color=control))

# Well, that's unsatisfying!  Try fill instead of color
ggplot(data=college) +
  geom_bar(mapping=aes(x=region, fill=control))

# How about average tuition by region?
# First, I'll use some dplyr to create the right tibble
college %>%
  group_by(region) %>%
  summarize(average_tuition=mean(tuition))

# And I can pipe that straight into ggplot
college %>%
  group_by(region) %>%
  summarize(average_tuition=mean(tuition)) %>%
  ggplot() +
  geom_bar(mapping=aes(x=region, y=average_tuition))

# But I need to use a column graph instead of a bar graph to specify my own y
college %>%
  group_by(region) %>%
  summarize(average_tuition=mean(tuition)) %>%
  ggplot() +
  geom_col(mapping=aes(x=region, y=average_tuition))


