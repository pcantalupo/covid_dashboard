library(tidyverse)
college <- read_csv('http://672258.youcanlearnit.net/college.csv')
college <- college %>%
  mutate(state=as.factor(state), region=as.factor(region),
         highest_degree=as.factor(highest_degree),
         control=as.factor(control), gender=as.factor(gender),
         loan_default_rate=as.numeric(loan_default_rate))

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


# Get linear model statistics.  Too much work, use ggpubr package instead
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


sessionInfo()

