library(data.table)

path <- getwd()

# Get Activity Labels and Features
activity_labels <- fread(file.path(path, "activity_labels.txt"), col.names = c("classLabels", "activity"))
features <- fread(file.path(path, "features.txt"), col.names = c("index", "featureName"))
# Extracting mean and std (standard deviation) from features table
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureName])
measurements <- features[featuresWanted, featureName]
measurements <- gsub('[()]', '', measurements)


# Load train datasets
train <- fread(file.path(path, "train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "train/y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)



# Load test datasets
test <- fread(file.path(path, "test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "test/y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets
combined <- rbind(train, test)

# Convert classLabels to activityName basically. More explicit. 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activity_labels[["classLabels"]]
                                 , labels = activity_labels[["activity"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])


data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
