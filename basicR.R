# Calculator
2 + 2
10^3

# Directory
getwd()
setwd("/path/to/new/work/directory")  # use Projects in R Studio to set working directory to folder you are working in 

# Getting help
?mean

help.search('normal distribution')

help(package = 'stats')  # Packages tab in R studio

str(iris)   # structure of R object
?str

class(iris)



# Using Packages
install.packages("cowsay")  # installs files to operating system
library(cowsay)  # make it accessible to our current code
cowsay::say()
say("Hello Hillman Academy students!", by = "cow")


library(datasets)   # one of the default base R packages
help(package = datasets)

head(iris)    # Show the first six lines of iris data
summary(iris) # Summary statistics for iris
plot(iris)    # Scatterplot matrix for iris  # Spread, Correlation,
hist(iris$Sepal.Width)   # Shape, Gaps, Outliers, Symmetry



# Vectors
x = c(4, 2, 6, 1, 2)   # numeric
typeof(x)
sort(x)
rev(x)
unique(x)

a = c("cat", "dog", "zebra", "fish", "dog")  # char
table(a)


## selecting vector elements
x[1]    # the 1st element

x[-3]   # all but the 3rd

x[x < 4]

x[x %in% c(2,6)]   # get elements in the set 2, 6


# Flow control
for (i in 1:4) {    # also While loops
  j = i + 10
  print (j)
}

if (i > 3) {
  print ('Yes')
} else {
  print ('No')
}


# Functions
concat = function (a, b) {
  c = paste(a, b)
  return(c)
}
concat("foo", "bar")



## math functions
x = rnorm(50)
mean(x) 
sd(x)   # standard deviation
median(x) 	#median
mad(x)
quantile(x, .9)  # get the 90% percentile
y <- quantile(x, c(.3,.84))
range(x)  #	range
sum(x) # 	sum
min(x) 	# minimum
max(x) # 	maximum


# Strings
grade = "A"
score = 94.5
paste("You got a score of ", score, " which is grade ", grade, sep="")
paste0("You got a score of ", score, " which is grade ", grade)

fruits <- c("apple", "oranges", "banana", "apricot")
vegetables <- c("cabbage", "spinach", "tomatoes")

grep("apple", fruits, value=TRUE)
grep("^ap", fruits, value=TRUE)



#Factors

#TODO


# Matrix

# TODO


# Lists

# TODO




# Data frames - like a Spreadsheet
df = data.frame(x = c(1:10), y = LETTERS[1:10])
df
View(df)
head(df)
dim(df); nrow(df); ncol(df)

# subsetting
df$x
df[1,]
df[,"x"]
df[2,2]

df[['x']]
column = 'x'
df[[column]]
df[[2]]


# Write/ Read files
write.csv(df, file = "mydata.csv")
df2 = read.csv(file = "mydata.csv")# row.names = 1)  # careful, need row.names
df2


# Read and write data
read.table("textfile.txt")
?read.table
df = read.delim("textfile.txt")
write.table(df, "textfile_write.txt")
?write.table
write.table(df, "textfile_write.txt", quote=FALSE, row.names = FALSE)






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


# Distributsions

# TODO
