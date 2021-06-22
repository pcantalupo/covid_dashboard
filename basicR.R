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

animals = c("cat", "dog", "zebra", "fish", "dog")  # char
table(animals)


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



# Factors
fruit <- c(rep("grapes",5), rep("apples", 3))
summary(fruit) 
fruit <- factor(fruit)
str(fruit)
summary(fruit) 
plot(fruit)

newfruit = factor(fruit, levels = c("grapes", "apples"))
summary(newfruit) 
plot(newfruit)



# Matrix
y<-matrix(1:20, nrow=5,ncol=4) # generates 5 x 4 numeric matrix

# another example
cells <- c(1,26,24,68)
rnames <- c("R1", "R2")
cnames <- c("C1", "C2")
mymatrix <- matrix(cells, nrow=2, ncol=2, byrow=TRUE,
                   dimnames=list(rnames, cnames))

#Identify rows, columns or elements using subscripts.
y[,4] # 4th column of matrix
y[3,] # 3rd row of matrix
y[2:4,1:3] # rows 2,3,4 of columns 1,2,3 



# Lists - An ordered collection of objects (components). A list allows you to gather a variety of (possibly unrelated) objects under one name.
# example of a list with 4 components - a string, a numeric vector, a matrix, and a scaler
w <- list(name="Fred", mynumbers=1:10, mymatrix=y, age=5.3)

#Identify elements of a list using the [[]] convention.
w[2] # 2nd component of the list as a list
w[[2]] # 2nd component of the list
w[["mynumbers"]] # component named mynumbers in list





# Data frames - like a Spreadsheet
df = data.frame(x = c(1:10), y = LETTERS[1:10])
df
head(df)
dim(df); nrow(df); ncol(df)
typeof(df)

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

# another example
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

par(mfrow=c(2,2)) # Change the panel layout to 2 x 2
plot(m)
par(mfrow=c(1,1)) # Change back to 1 x 1

summary(m)
abline(m)
anova(m)
coef(m)
confint(m)
residuals(m)


