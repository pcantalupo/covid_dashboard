library(datasets)   # one of the default base R packages

head(iris)    # Show the first six lines of iris data
summary(iris) # Summary statistics for iris
plot(iris)    # Scatterplot matrix for iris  # Spread, Correlation,
hist(iris$Sepal.Width)   # Shape, Gaps, Outliers, Symmetry


# Install a package
install.packages("cowsay")  # installs files to operating system
library(cowsay)  # make it accessible to our current code
say("moo", by = "cow")

# Calculator
2 + 2
10^3

# Directory
getwd()
setwd("/path/to/new/work/directory")


# Vectors type
x = c(4, 2, 6, 1, 2)   # numeric
typeof(x)
sort(x)
unique(x)

a = c("cat", "dog", "zebra", "fish", "dog")  # char
table(a)

## selecting vector elements
x[1]
x[x < 4]


# Data frames - like a Spreadsheet
df = data.frame(x = c(1,2,3), y = c("a", "b", "c"))
df

# subsetting
df$x
df[1,]
df[,"x"]
df[2,2]


# Write/ Read files
write.csv(df, file = "mydata.csv")
df2 = read.csv(file = "mydata.csv", row.names = 1)  # careful, need row.names
df2


# Strings
grade = "A"
score = 94.5
paste("You got a score of ", score, " which is grade ", grade, sep="")
paste0("You got a score of ", score, " which is grade ", grade)


# Statistics - Linear models (regression)
  # using a variable(s) to predict the value of another
h = women$height   # base R dataset called 'women"
w = women$weight
plot(h, w)
m = lm(w ~ h)
summary(m)
abline(m)
anova(m)
coef(m)
confint(m)
residuals(m)
