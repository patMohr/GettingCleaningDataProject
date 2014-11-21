# This code takes the data from the "Human Activity Recognition Using Smartphones Data Set" from the UCI Machine Learning Repository.  
# Data is read, processed and tranformed to create a tidy data set that summarizes experiment results across many different variables.

# Overall plan is to complete 5 steps:
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement.
# 3. Use descriptive activity names to name the activities in the data set.
# 4. Appropriately label the data set with descriptive variable names.
# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.
# Note: Tidy data principles are laid out in this journal article by Hadley Wickham: http://www.jstatsoft.org/v59/i10/paper

# First retrieve raw data from the following URL, https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip, and unzip the file.

############
#USER INPUT#
############

# After unzipping the file, define the main directory (which contains the README.txt file) as the working directory. A sample is below.
# setwd("//Users//patm12//documents//coursera//gettingCleaningData//project//UCI HAR dataset//")

# This directory will be assigned to the object "mainDir"
mainDir<-getwd()

################
#Pre-processing#
################

# Load the required R libraries before processing.
library(dplyr)
library(reshape2)
library(tidyr)

# We will be working with data from two subdirectories, test and train.  Predefine those directories now.
testDir<-paste(mainDir,"//test//",sep="")
trainDir<-paste(mainDir,"//train//",sep="")

# Common data for both sets are in the mainDir (features.txt and activity_labels.txt).  Load those files now.
setwd(mainDir)
# Features.txt contains information regarding the names of the fields in the X_text.txt file. Read and take the second column as a vector.
measurementNames<-read.table("features.txt",header=F,stringsAsFactors=F)[,2]
# Activity_labels.txt contains a mapping between a numeric value for the six activities and the english description.
activityLabels<-read.csv("activity_labels.txt",stringsAsFactors=F,sep=" ",header=F)
names(activityLabels)<-c("activityNumber","activity")

##################################################################
# 1. Merge the training and the test sets to create one data set.#
##################################################################

# Create test#
setwd(testDir)

# Read in the subjects as a vector
subject<-read.table("subject_test.txt",header=F)[,1]

# Read in activities as a vector
activityNumber<-read.table("y_test.txt",header=F,stringsAsFactors=F)[,1]

# Read in summaries of measurements.  This is the matrix of measurements without subject and activity labels and without variable titles.
test<-read.table("X_test.txt",header=F)

# Replace the names with measurementNames
names(test)<-measurementNames

#add the subjects and activityNumber to test
test<-cbind(subject,activityNumber,test)

#now do the same for train
setwd(trainDir)

# Read in the subjects as a vector
subject<-read.table("subject_train.txt",header=F)[,1]

# Read in activities as a vector
activityNumber<-read.table("y_train.txt",header=F,stringsAsFactors=F)[,1]

# Read in summaries of measurements.  This the matrix of measurements without subject and activity labels and without variable titles.
train<-read.table("X_train.txt",header=F)

# Replace the names with measurementNames
names(train)<-measurementNames

# add the subjects and activityNumbers to train
train<-cbind(subject,activityNumber,train)

# Now bring test and train together in to a complete set called "bodyMeasures"
bodyMeasures<-rbind(test,train)

#################################################################################################
# Step 2. Extract only the measurements on the mean and standard deviation for each measurement.#
#################################################################################################

# First find mean columns.  This will include both columns with "mean()" at the end and "mean" earlier in the name.
meanCols<-grep("mean",names(bodyMeasures))
# Then find std dev columns.  This will include both columns with "std()" at the end and "std" earlier in the name.
stdCols<-grep("std",names(bodyMeasures))
# Reduce the "bodyMeasures" data frame to only means and stdev cols but don't delete the first two columns (we want to retain subject and activityNumber)
bodyMeasures<-bodyMeasures[,c(1,2,meanCols,stdCols)]

#################################################################################
# Step 3. Use descriptive activity names to name the activities in the data set.#
#################################################################################

# Using "merge", data sets will automatically be merged on the only common field name: activityNumber.  
# Rows will be re-ordered but it doesn't matter because the data is now a complete set--no more cbinding or rbinding.
bodyMeasures<-merge(activityLabels,bodyMeasures)
# Remove the activity number.
bodyMeasures$activityNumber<-NULL

############################################################################
# Step 4. Appropriately label the data set with descriptive variable names.#
############################################################################

# Clean up the names to make the data set more readable.  For example we want to convert something like 'tBodyAcc-mean()-Z' to 'tBodyAccMeanZ'.
# "Camel case" naming convention is strictly enforced. http://en.wikipedia.org/wiki/CamelCase

# Define a vector of the current names of the dataframe.  (We will do all operations on this vector and use it to replace the old names.)
nms<-names(bodyMeasures)
# Get rid of minus signs
nms<-gsub("\\-","",nms)
# Get rid of open, close parentheses
nms<-gsub("\\(\\)","",nms)
# Convert 'mean' to 'Mean' for consistent Camel case labeling
nms<-gsub("mean","Mean",nms)
# Convert 'std' to 'Std' for consistent Camel case labeling
nms<-gsub("std","Std",nms)
# There seems to be mislabled variables.  Change "BodyBody" to "Body"
nms<-gsub("BodyBody","Body",nms)
# Convert Gyro to Gyroscope
nms<-gsub("Gyro","Gyroscope",nms)
# Convert Acc to Accelerometer
nms<-gsub("Acc","Accelerometer",nms)
# Convert Mag to Magnitude
nms<-gsub("Mag","Magnitude",nms)
# Convert Freq to Frequency
nms<-gsub("Freq","Frequency",nms)
# Now replace the old names with the new names
names(bodyMeasures)=nms

###########################################################################################################################
# Step 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.#
###########################################################################################################################

# First calculate average by subjects
# Use dplyr to calculate the average per subject for all measurements
avgBySubject<-bodyMeasures[,-1] %>% #exclude column 1 because this is the "activity" column
  group_by(subject) %>%
  summarise_each(funs(mean(.,na.rm=T)))

# Now do the same for activities
avgByActivity<-bodyMeasures[,-2] %>%  #exclude column 2 because this is the "subject" column
  group_by(activity) %>%
  summarise_each(funs(mean(.,na.rm=T)))

# Before combining the sets we need them to have consistent names.
names(avgBySubject)[1]<-"subjectActivityName"
names(avgByActivity)[1]<-"subjectActivityName"

# Add a column to each set indicating whether the mean is for an activity or a subject
avgBySubject<-cbind(subjectOrActivity="subject",avgBySubject)
avgByActivity<-cbind(subjectOrActivity="activity",avgByActivity)

# Bring the two together in to a common data set called "tidy"
tidy<-rbind(avgBySubject,avgByActivity)

# Convert to a narrow and long dataset using tidyR's gather function
tidy<-gather(tidy,measurementType,meanValue,tBodyAccelerometerMeanX:fBodyGyroscopeJerkMagnitudeStd)

# Get rid of factor levels that dplyr created.
tidy$subjectOrActivity<-as.character(tidy$subjectOrActivity)
tidy$measurementType<-as.character(tidy$measurementType)

# This results in a data set containing 4 fields: subjectOrActivity, subjectActivityName, measurementType and meanValue:
# subjectOrActivity subjectActivityName         measurementType meanValue
#           subject                   1 tBodyAccelerometerMeanX 0.2656969
#           subject                   2 tBodyAccelerometerMeanX 0.2731131
#           subject                   3 tBodyAccelerometerMeanX 0.2734287

# However, we actually have multiple variables in a single column (measurementType) which is not "tidy"!  
# For example, this field simultaneously contains Fourier or time domain measure, X/Y/Z axis,body/gravity measure,accelerometer/gyroscope.
# All of these are different variables and should be represented in different columns. 
# For more information please see section 3.2 of Hadley Wickham's "Tidy Data" article (http://www.jstatsoft.org/v59/i10/paper)   

# The rest of the code deconstructs this field in to those separate variables.
# The resulting data set is far more granular than the above data set. It allows users to easily slice and dice by more dimensions than the simple 4 field dataframe above.

# Create a field to identify the filter type: t = time domain, f= Fast Fourier Transform
tidy$timeOrFourier<-ifelse(substr(tidy$measurementType,1,1)=="t","t","f")

# Create a field to differentiate between Body and Gravity measures.  
# Note that one of the variable names is mislabeled as "bodybody" in the original data set. Use of grep allows us to properly classify this measure as a "body" measure.
tidy$bodyOrGravity<-NA
tidy$bodyOrGravity[grep("Body",tidy$measurementType)]<-"body"
tidy$bodyOrGravity[grep("Gravity",tidy$measurementType)]<-"gravity"

# Create a field to differentiate between accelerometer and gyroscope
tidy$accOrGyro<-NA
tidy$accOrGyro[grep("Accelerometer",tidy$measurementType)]<-"accelerometer"
tidy$accOrGyro[grep("Gyroscope",tidy$measurementType)]<-"gyroscope"

# Create a field to differentiate between mean and std dev
tidy$meanOrStd<-NA
tidy$meanOrStd[grep("Mean",tidy$measurementType)]<-"mean"
tidy$meanOrStd[grep("Std",tidy$measurementType)]<-"stdDev"

# Create a field to identify the axis being measured (X,Y or Z).  Note: this is not available for all measures.  
# First get the last letter from each name.
tidy$axis<-substr(tidy$measurementType,nchar(tidy$measurementType),nchar(tidy$measurementType))
# If not X, Z, or Y set to NA
tidy$axis<-ifelse(tidy$axis=="X","X",ifelse(tidy$axis=="Y","Y",ifelse(tidy$axis=="Z","Z",NA)))

# Create a column for Jerk
tidy$jerk<-NA
tidy$jerk<-grepl("Jerk",tidy$measurementType)

# Create a column for Magnitude
tidy$magnitude<-NA
tidy$magnitude<-grepl("Magnitude",tidy$measurementType)

# Create a column for Frequency
tidy$frequency<-NA
tidy$frequency<-grepl("Frequency",tidy$measurementType)

# Result is an 12 column data frame as follows:
# subjectOrActivity subjectActivityName         measurementType meanValue timeOrFourier bodyOrGravity     accOrGyro meanOrStd axis  jerk magnitude frequency
#           subject                   1 tBodyAccelerometerMeanX 0.2656969             t          body accelerometer      mean    X FALSE     FALSE     FALSE
#           subject                   2 tBodyAccelerometerMeanX 0.2731131             t          body accelerometer      mean    X FALSE     FALSE     FALSE
#           subject                   3 tBodyAccelerometerMeanX 0.2734287             t          body accelerometer      mean    X FALSE     FALSE     FALSE

# Please see codeBook.md for interpretation of these fields.

# Sort the data set
tidy<-tidy[order(tidy$subjectActivityName),]
# Write the results to the tidy data output directory
setwd(mainDir)
write.table(tidy,file="tidy.txt",row.names=F)

# Print the location of file is as follows:
print(paste("The tidy data was saved in this location:",getwd(),"/tidy.txt",sep=""))

##################
#Reading the data#
##################

# Assuming that the mainDir variable was entered correctly and tidyDataOutputDir was generated, this data set can be read with the following command:
setwd(mainDir)
tidy<-read.table("tidy.txt",header=T)
