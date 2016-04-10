##Getting and Cleaning Data Assignment Week 4

fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp<-tempfile()

#Downloading and unzipping data
if(!file.exists("UCI HAR Dataset")){
  download.file(fileUrl,temp)
  unzip(temp)
}
unlink(temp)

#Loading list of features and activity names
features<-read.table("UCI HAR Dataset/features.txt")
activity<-read.table("UCI HAR Dataset/activity_labels.txt")

#Extracting only the measurements on mean and standard deviation on the measurements
featuresmeanstd.Row <- intersect(grep(".*mean.*|.*std.*", features[,2]),grep(".*meanFreq",features[,2],invert=TRUE))
featuresmeanstd <-intersect(grep(".*mean.*|.*std.*", features[,2],value=TRUE),grep(".*meanFreq",features[,2],invert=TRUE,value=TRUE))

#Making the field names more descriptive
featuresmeanstd=gsub("-mean()","Mean",featuresmeanstd)
featuresmeanstd=gsub("-std()","Std",featuresmeanstd)
featuresmeanstd=gsub("[()]","",featuresmeanstd)
featuresmeanstd=gsub("[-]","",featuresmeanstd)
featuresmeanstd=gsub("BodyBody","Body",featuresmeanstd)

#Loading the training datasets
train.Data <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresmeanstd.Row]
train.Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train.Activity <- read.table("UCI HAR Dataset/train/Y_train.txt")
train.Sample<-"train"
train <- cbind(train.Subjects, train.Activity,train.Sample,train.Data)
colnames(train) <- c("subject", "activity","sample", featuresmeanstd)

#Loading the test datasets
test.Data <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresmeanstd.Row]
test.Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test.Activity <- read.table("UCI HAR Dataset/test/Y_test.txt")
test.Sample<-"test"
test <- cbind(test.Subjects, test.Activity,test.Sample,test.Data)
colnames(test) <- c("subject", "activity","sample", featuresmeanstd)

#Merging the training and test datasets
dataframe<-rbind(train,test)
colnames(dataframe) <- c("subject", "activity","sample", featuresmeanstd)

#Adding descriptive activity names to name the activities in the data set
dataframe$activity <- factor(dataframe$activity, levels = activity[,1], labels = activity[,2])
#Converting Subject into a factor
dataframe$subject <- as.factor(dataframe$subject)

#Creating a tidy data set with the average of each variable for each activity and each subject.
#Using package reshape
melteddata<-melt(dataframe,id=c("activity","subject","sample"))
tidydataset<-cast(melteddata,activity+subject+sample~variable,mean)

#Exporting the tidy dataset to a text file
write.table(tidydataset, "c:/tidydataset.txt", sep="\t")