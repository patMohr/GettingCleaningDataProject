# Codebook
#### Section 1: Background
#### Section 2: Brief Description of Original Data Set
#### Section 3. Structure of the Original Data
#### Section 4. Units
#### Section 5. Processing Required to Summarize Measures by Subject and Activity
#### Section 6. Description of the Resulting Tidy Data Set

—————————————————————————————————————————————————

#### Section 1. Background
This document lays out the basic structure of the “Human Activity Recognition Using Smartphones” data set with a view to describing the details required to interpret the results of a “tidy” data set that summarizes measurements by subject and activity.  

Interested readers who want to understand full details of the dataset are encouraged to read the documentation provided with the dataset from the UCI Machine Learning website. 
https://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Specifically, the README.TXT file and the features_info.txt file provide details on the original data set.

This particular repository should be considered an offset off the original data set where our goal is to summarize the average measurement by subject (across all activities) and by activity (across all subjects).  

The result of that analysis is a tidy dataset with the most granularity possible based on the original experimental design (please see details in section 5).  

#### Section 2: Brief Description of Original Data Set
Human Activity Recognition Using Smartphones Data Set can be downloaded from https://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI HAR Dataset.zip

The data represents the results of experiments to measure body motion via smartphones.  The experiments were carried out on 30 subjects performing 6 activities:
* Walking
* Walking Upstairs
* Walking Downstairs
* Sitting
* Standing
* Laying

For each activity, accelerometer and gyroscope readings for three dimensional movement were recorded.  This resulted in a total of six simultaneous measurements: * X axis acceleration * Y axis acceleration * Z axis acceleration * X axis angular velocity * Y axis angular velocity * Z axis angular velocity

For each of these six measures a large number of summary statistics were calculated, details of which can be found in the features_info.txt file provided with the original data set.

When the number of activities, two sets of 3 dimensional measures and the large number of summary statistics is considered, all together there are more than 560 summary measures provided per experiment.

#### Section 3. Structure of the Original Data
After unzipping the file, the data set is structured as follows:
Main data set contains four text files:	 
1. README.txt : contains a description of the dataset.

2. activity_labels.txt : contains descriptive labels of the six activities and the associated number which is used in the other datasets.

3. Features_info.txt: provides a detailed explanation of the different measures taken as well as the summary statistics which were collected for each measure.

4. Features.txt: provides a complete list of summary statistics calculated for each experiment.

The results of the experiment are broken in to two subdirectories with an identical structure: “test” and “train.”

The “test” subdirectory contains 3 files and a subdirectory for the “test” observations:

1. X_test.txt contains the actual summary measures per subject and activity in a matrix with 2947 rows and 562 columns.

2. Subject_test.txt contains a vector of the subject measured in each row of X_test.  This is a vector with  length 2947.

3. y_test.txt contains a vector of the activity being measured in each row of X_test.  This is a vector with  length 2947.  Note that activities are provided as a number and the mapping to more descriptive activities can be found by using the activity_lables.txt in the main directory.

The subdirectory “inertial” contains individual measures of the experiments, prior to the calculation of summary statistics provided in the X_test.txt file.

#### Section 4. Units
All data in the experiment were normalized and bounded within -1 and +1.

#### Section 5. Processing Required to Summarize Measures by Subject and Activity
An R script titled run_analysis.R is provided to do the following:
* Combine the HAR test and training datasets of summary statistics into a single data set.
* Reduce the measures to only include those measures that calculated either a mean or a standard deviation from the experiments.
* From that resulting data set, calculate the average measure across all subjects for a given activity and the average across all activities for a given subject.
* Reformat the resulting dataset in to a tidy data set which is “narrow and thin.”
* This file is included in this repository under the name “tidyAvgBySubjectByActivity.txt”

#### Section 6. Description of the Resulting Tidy Data Set
The final tidy data set contains the following fields:
* SubjectOrActivity: indicates whether the mean is calculated by subject (across all activities) or by activity (across all subjects)
* subjectActivityName: if subjectOrActivity=”activity” this column will contain the activity name; if subjectOrActivity=”subject” it will contain the subject number.  For subjects, the value of this field will be a number ranging from 1 to 30.  For activities this field will be populated with one of the following:
	+ Walking
	+ Walking_Upstairs
	+ Walking_Downstairs
	+ Sitting
	+ Standing
	+ Laying
* timeOrFourier: the original data set provides two styles of data “time variant” (denoted by “t” in this field) and Fast Fourier Transformed (denoted by “f”)
* bodyOrGravity: indicates whether the measurement is of body (denoted by “body”) or gravity (denoted by “gravity”)
* accOrGyro: indicates whether the measurement was taken from the smartphone gyroscope (denoted by “gyroscope”) or accelerometer (denoted by “accelerometer”)
* meanOrStd: indicates whether the mean is being calculated on a mean measurement (denoted by “mean”) or a standard deviation measurement (denoted by “stdDev”).
* axis: indicates which axis is being measured (X, Y, Z or NA)
* jerk: a logical vector indicating if the measure is of a jerk or not
* magnitude: a logical vector indicating if the measure is of a magnitude or not
* frequency: a logical vector indicating if the measure is of a frequency or not
* meanValue: the actual mean value calculated by subject or activity for the experimental data defined by fields 3:10 of the tidy data set


