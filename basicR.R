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

library(datasets)   # one of the default base R packages
help(package = datasets)


# Explore 'iris' dataset
str(iris)   # structure of R object
?str
View(iris)
class(iris)
head(iris)    # Show the first six lines of iris data
nrow(iris); ncol(iris); dim(iris)
summary(iris) # Summary statistics for iris
plot(iris)    # Scatterplot matrix for iris  # Spread, Correlation,
hist(iris$Sepal.Width)   # Shape, Gaps, Outliers, Symmetry
boxplot(Sepal.Width ~ Species, data = iris)



# Installing packages
install.packages("cowsay")  # installs files to operating system
library(cowsay)  # make it accessible to our current code
say("Hello Hillman Academy students!", by = "cow")



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
x[x %in% c(2,6)]   # get elements in the set 2, 6
x[x < 4]  # be careful with relational operators (see below)

x[5] = NA # set 5th element to NA
x[x < 4]  # whoa, NA is not less than 4
?`<`      # does not just return TRUE or FALSE values (can be NA as well)
x[which(x < 4)] # always wrap relational operators inside which()


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


# Strings
grade = "A"
score = 94.5
paste("You got a score of ", score, " which is grade ", grade, sep="")
paste0("You got a score of ", score, " which is grade ", grade)



# Pattern matching
fruits <- c("apple", "oranges", "banana", "apricot")
grep("apple", fruits, value=TRUE)
grep("^ap", fruits, value=TRUE)   # ^ matches the beginning of the line
?grep   # read more about regular expressions



# Factors
fruit <- c(rep("grapes",5), rep("apples", 3))
summary(fruit) 
fruit <- factor(fruit)
str(fruit)
summary(fruit) 
plot(fruit)

newfruit = factor(fruit, levels = c("grapes", "apples"))  # reordering levels
summary(newfruit) 
plot(newfruit)



# Matrix
y<-matrix(1:20, nrow=5,ncol=4) # generates 5 x 4 numeric matrix

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
df = data.frame(numbers = c(1:10), letters = LETTERS[1:10])
df
head(df)
dim(df); nrow(df); ncol(df)
typeof(df)

# subsetting
df$numbers
df[1,]     #  [rows, columns]
df[,"numbers"]
df[2,2]

df[['letters']]  #  [[]] only deals with columns
column = 'letters'
df[[column]]
df[[2]]


# Write/ Read files
write.csv(df, file = "assets/mydata.csv")   # default is to output rownames
read.csv(file = "assets/mydata.csv")# row.names = 1)  # careful, need to specify row.names

# another example
read.table("assets/people.txt")   #why are column headers in Row #1
?read.table
people = read.table("assets/people.txt", header = TRUE)
write.table(people, "assets/people_write.txt")
?write.table
write.table(df, "assets/people_write.txt", quote=FALSE, row.names = FALSE)




# Statistics 
# Basic math functions
n = rnorm(50)
mean(n) 
sd(n)   # standard deviation
median(n) 	#median
mad(n)
sum(n) # 	sum
quantile(n, .9)  # get the 90% percentile
range(n)  #	range
min(n) 	# minimum
max(n) # 	maximum


# Linear models (regression) - using a variable(s) to predict the value of another
women   # base R dataset called 'women"
plot(women)
m = lm(weight ~ height, data=women)   # create linear model
abline(m)

par(mfrow=c(2,2)) # Change the panel layout to 2 x 2
plot(m)
par(mfrow=c(1,1)) # Change back to 1 x 1

summary(m)
anova(m)
coef(m)
confint(m)
residuals(m)
cor(women)



# Miscellaneous
# Creating your own function
concat = function (a, b) {
  string = paste(a, b)
  return(string)
}
concat("foo", "bar")



sessionInfo()  # best practice to keep track of the package versions that were used


