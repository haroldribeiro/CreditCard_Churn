library(Information) #IV 
library(HH) #VIF (Multicollinearity) 
library(InformationValue) #KS and ROC
library(caret) #confusion matrix
library(ggplot2) #data visualization

#-------------------------------------------#
# 1.IMPORTING THE DATASET AND FIRST CHECKS  #
#-------------------------------------------#
#Setting my directory 
setwd("/Users/haroldribeiro/OneDrive/Documents/Studies/Data Science/R Portfolio/BankChurn")

#Removing scientific notation 
options(scipen=999)

#Importing the dataset and removing column clientnum
churn_data <- as.data.frame(read.csv("BankChurners.csv",sep = ";"))[, -1]

#Showing the structure of the variables and some samples of values
str(churn_data)

#checking missing value
sum(is.na(churn_data))

#Creating a binary target variable
churn_data$target <- ifelse(churn_data$Attrition_Flag == "Attrited Customer",1,0)

#Dropping  original column 
churn_data <- churn_data[,-1]

#------------------------------------------------------------------------------------

#--------------------------------------------#
# 2. IV (Information Value Analysis)         #
#--------------------------------------------#

IV <- create_infotables(data = churn_data, y = "target")
IV$Summary

#-------------------------------------------------#
# 3. Splitting the dataset between train and test #
#-------------------------------------------------#

#Setting the same random seed
set.seed(20210516) 

#Qty of records that represents 70% of the data
sample.size <- floor(0.70 * nrow(churn_data))

#filtering the index records
train.index <- sample(seq_len(nrow(churn_data)), size = sample.size)

#recovering the train data
churn_data_train <- churn_data[train.index, ]

#test data
churn_data_test <- churn_data[- train.index, ]


#------------------------------------------------------------------------------------

#---------------------------------------------#
#4. Logistic Regression model
#---------------------------------------------#

#-- ASSUMPOTION --#
#1) We're going to use 90% level of confidence
#2) features  > 0.03 of IV 
#2) We're going to use the BACKWARD method to reduce the irrelevant features


train_churn_model <- glm(target ~ Total_Trans_Ct+
                           Total_Trans_Amt+
                           Total_Revolving_Bal+
                           Total_Ct_Chng_Q4_Q1+
                           #Avg_Utilization_Ratio+ #0.82873 (p-value) first
                           Months_Inactive_12_mon+
                           Contacts_Count_12_mon+
                           #Total_Amt_Chng_Q4_Q1+ #0.214940 (p-value) second
                           Total_Relationship_Count+
                           Avg_Open_To_Buy
                         #Credit_Limit #NA pvalue
                         ,family=binomial (link='logit'),data=churn_data_train)
summary(train_churn_model)

#AIC 3481.9 all features
#AIC 3479.5 (without avg_utilization_ratio+total_amt_chng_Q4_Q1)

#------------------------------------------------------------------------------------

#---------------------------------------------#
#5. Identifying  Multicollinearity (VIF)
#---------------------------------------------#

# I don't identify huge sign of multicollinearity assuming VIF > 5
vif(train_churn_model)


#---------------------------------------------#
#6. Model Performance 
#---------------------------------------------#


#------------------
# Train dataset
#------------------
#Appeding the predict value
churn_data_train$pred_prob <- predict(train_churn_model,churn_data_train,type="response") 

#applying the same threshold of the dataset 16.06%
churn_data_train$pred <-  ifelse(churn_data_train$pred_prob >=0.1606 ,1,0)


# 1. KS and ROC

ks_stat(actuals=churn_data_train$target, predictedScores=churn_data_train$pred_prob)
#KS (Kolmogorov-Smirnov) 0.6818

plotROC(actuals=churn_data_train$target, predictedScores=churn_data_train$pred_prob)
#AUC (Area under the curve): 0.9169

# 2. Confusion Matrix

#target as factor
churn_data_train$target_fct <- as.factor(churn_data_train$target)

#predit as factor
churn_data_train$pred_fct <- as.factor(churn_data_train$pred)

#ConfusionMatrix
caret::confusionMatrix(data = churn_data_train$pred_fct, reference = churn_data_train$target_fct)

#-------------------------------------------------------------------

# Test dataset

# appending predict values
churn_data_test$pred_prob <- predict(train_churn_model,churn_data_test,type="response")

#applying the same threshold of the dataset 16.06%
churn_data_test$pred <-  ifelse(churn_data_test$pred_prob >=0.1606 ,1,0)

#1. KS and ROC

ks_stat(actuals = churn_data_test$target,  predictedScores = churn_data_test$pred_prob)
# KS 0.6711

plotROC(actuals = churn_data_test$target,  predictedScores = churn_data_test$pred_prob)
#AUC (Area under the curve): 0.9168

# 2. Confusion Matrix

#target as factor
churn_data_test$target_fct <- as.factor(churn_data_test$target)

#predit as factor
churn_data_test$pred_fct <- as.factor(churn_data_test$pred)

caret::confusionMatrix(data = churn_data_test$pred_fct, reference = churn_data_test$target_fct)



# Creating a visualization of model performance

bar_data <- data.frame(performance=rep(c("Accuracy","Sensitivity","Specificity"),2),
                       dataset= c(rep("train",3),rep("test",3)),
                       values = c(0.8438,0.8429,0.8487 #train
                                  ,0.8384,0.8384,0.8386 #test
                                  )
                      
                       
      )

#sorting bar 
bar_data$dataset <- factor(bar_data$dataset, levels = c("train", "test"))


#bar plot
ggplot(data=bar_data, aes(x=dataset, y=values, fill=performance)) +
  geom_bar(position = "dodge", stat = "identity")+
  geom_text(aes(label=values),vjust=1.7, size=3.5, position = position_dodge(0.9))+
  theme_minimal()



