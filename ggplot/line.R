library(tidyverse)
college <- read_csv('http://672258.youcanlearnit.net/college.csv')
college <- college %>%
  mutate(state=as.factor(state), region=as.factor(region),
         highest_degree=as.factor(highest_degree),
         control=as.factor(control), gender=as.factor(gender),
         loan_default_rate=as.numeric(loan_default_rate))

# We had a nice plot of tuition vs. SAT scores when we worked with scatterplots
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control))

# What if we wanted to convert this to a line graph?
ggplot(data=college) +
  geom_line(mapping=aes(x=tuition, y=sat_avg, color=control))

# Wow, that's really noisy.  Let's add the points back in
ggplot(data=college) +
  geom_line(mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control))

# I can also write this a different way
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_line() +
  geom_point()

# I can use the geom_smooth geometry to fit a line instead of connecting every point
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth() +
  geom_point()

# Maybe add some transparency to just the points to make the line stand out more
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth() +
  geom_point(alpha=1/2)

# Try more transparency
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth() +
  geom_point(alpha=1/5)

# And remove the confidence interval from the smoother
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth(se=FALSE) +
  geom_point(alpha=1/5)
