library(tidyverse)
college <- read_csv('http://672258.youcanlearnit.net/college.csv')
college <- college %>%
  mutate(state=as.factor(state), region=as.factor(region),
         highest_degree=as.factor(highest_degree),
         control=as.factor(control), gender=as.factor(gender),
         loan_default_rate=as.numeric(loan_default_rate))

# We ended the last video creating a simple scatterplot
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg))

# Let's try representing a different dimension.  
# What if we want to differentiate public vs. private schools?
# We can do this using the shape attribute
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, shape=control))

# That's hard to see the difference.  What if we try color instead?
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control))

# I can also alter point size.  Let's do that to represent the number of students
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads))

# And, lastly, let's add some transparency so we can see through those points a bit
# Experiment with the alpha value a bit.
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1)

ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1/100)

ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1/10)

ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1/2)
