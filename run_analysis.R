# Setting working directory as the folder where downloaded files are saved
setwd("./UCI HAR Dataset")

# Reading each text data into R
trainlabels <- read.table("./train/y_train.txt", col.names="activity")
trainsubject <- read.table("./train/subject_train.txt", col.names="subject")
train <- read.table("./train/X_train.txt")

testlabels <- read.table("./test/y_test.txt", col.names="activity")
testsubject <- read.table("./test/subject_test.txt", col.names="subject")
test <- read.table("./test/X_test.txt")

# Reading variable names
features <- read.table("features.txt")
# Giving the data sets their variables' names
colnames(train) <- features[, 2]
colnames(test) <- features[, 2]

# Combining columns of descriptions for each activity and their corresponding labels
activity.labels <- read.table("activity_labels.txt", col.names=c("labels", "description"))
train.description <- merge(trainlabels, activity.labels, by.x="activity", by.y="labels", sort=FALSE)
test.description <- merge(testlabels, activity.labels, by.x="activity", by.y="labels", sort=FALSE)

# Extracting the measurements on the mean and standard deviation
test.extract <- cbind(test[,grep("mean[()]", names(test))], test[,grep("std[()]", names(test))])
train.extract <- cbind(train[,grep("mean[()]", names(train))], train[,grep("std[()]", names(train))])

# Adding the column of descriptions
test.extract <- cbind(test.extract, test.description)
train.extract <- cbind(train.extract, train.description)

# Adding column of subject IDs
test.extract <- cbind(test.extract, testsubject)
train.extract <- cbind(train.extract, trainsubject)

# Merging the training and test sets
merged.df <- merge(test.extract, train.extract, all=TRUE, sort=FALSE)

# Making the labels more readable
names(merged.df) <- sapply(names(merged.df), function(sub.obj){gsub("-|[(]|[)]", "", sub.obj)})
names(merged.df) <- sapply(names(merged.df), function(sub.obj){gsub("mean", "Mean", sub.obj)})
names(merged.df) <- sapply(names(merged.df), function(sub.obj){gsub("std", "Std", sub.obj)})

# Caculating the average of each variable for each activity and each subject
library(dplyr)
merged.tbl <- tbl_df(merged.df)
grouped <- group_by(merged.tbl, subject, description)
summarized <- summarise_each_(grouped, funs(mean), names(grouped)[-67]) # 68th: "activity"

# Data output
write.table(as.data.frame(summarized), file="courseproject.txt", row.name=FALSE)
