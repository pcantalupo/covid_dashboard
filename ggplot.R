library(Hmisc)
library(tidyverse)

# Load college data
college = read_csv('http://672258.youcanlearnit.net/college.csv')   # readr package
#college2 = read_csv("assets/college.csv") 
college

describe(college$loan_default_rate)   # what is that NULL?
college$loan_default_rate

college <- college %>%
  mutate(loan_default_rate=as.numeric(loan_default_rate))


# Scatterplots (w/ tidy data example)----

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
  scale_color_manual(values = c('green', 'blue')) # apply color alphabetically to the 'control' values
  
# Can also alter point size.  Let's do that to represent the number of students
# Add some transparency to see through the points using alpha value (default = 1)
# Add commas to y-axis values
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1/2) + 
  scale_y_continuous(labels = scales::comma)

# Break control into its own facets
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control, size=undergrads), alpha=1/2) + 
  scale_y_continuous(labels = scales::comma) + 
  facet_wrap(~ control)


# Tidy data example
table4a
table4a %>%
  ggplot(aes(x = country)) +
  geom_point(aes(y = `1999`), color = "blue") + 
  geom_point(aes(y = `2000`), color = "red") #+
#  geom_point(aes(y = `2001`))  # need to add separate geom_point for every year column

long = table4a %>% pivot_longer(c("1999","2000"), names_to='year', values_to ='cases')
long

long %>% ggplot() +
  geom_point(aes(x=country, y = cases, color=year), size = 3)

ggsave("plot.png", width = 5, height = 5)



# Line plots with linear regression ----

# The plot of tuition vs. SAT scores
ggplot(data=college) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control))

# What if we wanted to convert this to a line graph?
ggplot(data=college) +
  geom_line(mapping=aes(x=tuition, y=sat_avg, color=control))

# That's really noisy.  Let's add the points back in
ggplot(data=college) +
  geom_line(mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_point(mapping=aes(x=tuition, y=sat_avg, color=control))

# I can also write this a different way
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_line() +
  geom_point()

# Fit a curve with geom_smooth geometry instead of connecting every point
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth() +
  geom_point()

# Linear model instead of a curve (with some transparency)
ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth(method = "lm") +
  geom_point(alpha=1/2)


pub.lm = college %>% filter(control == "Public") %>% lm(sat_avg ~ tuition, .)
pri.lm = college %>% filter(control == "Private") %>% lm(sat_avg ~ tuition, .)

statspub = paste("PUBLIC   Adj R2 = ",   signif(summary(pub.lm)$adj.r.squared, 3),
              "Intercept =", signif(pub.lm$coef[[1]], 3),
              " Slope =",    signif(pub.lm$coef[[2]], 3),
              " P =",        signif(summary(pub.lm)$coef[2,4], 3))
statspri = paste("PRIVATE  Adj R2 = ",   signif(summary(pub.lm)$adj.r.squared, 3),
                  "Intercept =", signif(pri.lm$coef[[1]], 3),
                  " Slope =",    signif(pri.lm$coef[[2]], 3),
                  " P =",        signif(summary(pri.lm)$coef[2,4], 3))

ggplot(data=college, mapping=aes(x=tuition, y=sat_avg, color=control)) +
  geom_smooth(method = "lm") +
  geom_point(alpha=1/2) +
  labs(title = paste(statspub, statspri, sep="\n"))
# Use ggpubr package!



# Bar and Column plots ----

# How many schools are in each region? - use a bar graph
ggplot(data=college) +
  geom_bar(mapping=aes(x=region))

# Break it out by public vs. private
ggplot(data=college) +
  geom_bar(mapping=aes(x=region, color=control))

# Try fill instead of color
ggplot(data=college) +
  geom_bar(mapping=aes(x=region, fill=control))

# How about average tuition by region? -> Use dplyr to create the right tibble
college %>%
  group_by(region) %>%
  summarize(average_tuition=mean(tuition))

# And I can pipe that straight into ggplot
college %>%
  group_by(region) %>%
  summarize(average_tuition=mean(tuition)) %>%
  ggplot() +
  geom_bar(mapping=aes(x=region, y=average_tuition))

# But I need to use a column graph instead of a bar graph to specify my own y variable
college %>%
  group_by(region) %>%
  summarize(average_tuition=mean(tuition)) %>%
  ggplot() +
  geom_col(mapping=aes(x=region, y=average_tuition))



# Histograms ----

# Let's look at student body size
ggplot(data=college) +
  geom_bar(mapping=aes(x=undergrads))

# Histograms can help us by binning results
ggplot(data=college) +
  geom_histogram(mapping=aes(x=undergrads), origin=0)

# What if we want fewer groups? Let's ask for 4 bins
ggplot(data=college) +
  geom_histogram(mapping=aes(x=undergrads), bins=4, origin=0)

# Or 10 bins.
ggplot(data=college) +
  geom_histogram(mapping=aes(x=undergrads), bins=10, origin=0)

# Or we can specify the width of the bins instead
ggplot(data=college) +
  geom_histogram(mapping=aes(x=undergrads), binwidth=1000, origin=0)

ggplot(data=college) +
  geom_histogram(mapping=aes(x=undergrads), binwidth=10000, origin=0)



# Boxplots ----

# Let's try looking at tuition vs. control
ggplot(data=college) +
  geom_point(mapping=aes(x=control, y=tuition))

# One way I could visualize this better is by adding some jitter
ggplot(data=college) +
  geom_jitter(mapping=aes(x=control, y=tuition))

# But an even better way is with a boxplot
ggplot(data=college) +
  geom_boxplot(mapping=aes(x=control, y=tuition))

# add jitter back
ggplot(data=college, mapping=aes(x=control, y=tuition)) +
  geom_boxplot() +
  geom_jitter() 


sessionInfo()

