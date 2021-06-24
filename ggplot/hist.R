library(tidyverse)
college <- read_csv('http://672258.youcanlearnit.net/college.csv')
college <- college %>%
  mutate(state=as.factor(state), region=as.factor(region),
         highest_degree=as.factor(highest_degree),
         control=as.factor(control), gender=as.factor(gender),
         loan_default_rate=as.numeric(loan_default_rate))

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
