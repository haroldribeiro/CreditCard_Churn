library(descr) #pivot table 

#-------------------------------------------#
#1. IMPORTING THE DATASET AND FIRST CHECKS  #
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

#------------------------#
#2. EXPLORATORY ANALYSIS
#------------------------#

## 2.1 DESCRIPIVE ANALYSIS

### 2.1.1 UNIVARIATE ANALYSIS

# Quantitative variables quick description
summary(churn_data[, c(-2,-4,-5,-6,-7)])

hist(churn_data$Customer_Age)
hist(churn_data$Months_on_book)

#Qualitative variables
par(mfrow=c(1,1)) 

freq(churn_data$target) #Target variable - there is 16.06% churn in our data set
freq(churn_data$Gender) #Balanced proportion of men and women 
freq(churn_data$Education_Level) #Most of customers have graduation degree (30%)
freq(churn_data$Marital_Status) #The majority of the customers are married
freq(churn_data$Income_Category) #35.16% of the customer earns  less than $40K yearly
freq(churn_data$Card_Category)#Almost all the customer have "Blue Category card"93.18%




### 2.1.2 BIVARIATE ANALYSIS


#Quantitative variables
par(mfrow=c(2,2)) #matrix 2 x 2 

# Age variable there is not a good description comparing against the target variable
boxplot(churn_data$Customer_Age~churn_data$target, main="Age (years)" 
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)

# Dependent variable show that 75% of the customers who left has between 2 and 3 dependents
boxplot(churn_data$Dependent_count~churn_data$target, main="# of Dependents" 
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)

# Time of relationship variable there is not a good description comparing against the target variable
boxplot(churn_data$Months_on_book~churn_data$target, main="Time of relationship (Months)" 
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)

# Customers who have less qty of products are more likely to churn
boxplot(churn_data$Total_Relationship_Count~churn_data$target, main="# of Products"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)

#Customers who have stayed between 2 and 3 inactive months they will have more likely to churn
boxplot(churn_data$Months_Inactive_12_mon~churn_data$target, main="# of months inactives last 12 months"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)

#Customers who received more contacts in the last 12 months have more likelihood to churn
boxplot(churn_data$Contacts_Count_12_mon~churn_data$target, main="# of Contact last 12 months"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)

# Credit limit it is not so significant but there are a difference between who churned or not
boxplot(churn_data$Credit_Limit~churn_data$target, main="Credit Limit"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

# Customers who have fewer total revolving balance have more likelihood to churn
boxplot(churn_data$Total_Revolving_Bal~churn_data$target, main="Total Revolving Balance"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

#There aren't a good description against the target variable
boxplot(churn_data$Avg_Open_To_Buy~churn_data$target, main="Avg Open to buy last 12 months"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

#There aren't a good description against the target variable although don't have many outliers 
# for customer who churned
boxplot(churn_data$Total_Amt_Chng_Q4_Q1~churn_data$target, main="Change in Transaction Amount (Q4 over Q1)"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

# Customers who churned spent less between the last 12 months
boxplot(churn_data$Total_Trans_Amt~churn_data$target, main="Total Transaction Amount Last 12 months"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

par(mfrow=c(1,1)) 
# Customers who churned made less transactions between the last 12 months
boxplot(churn_data$Total_Ct_Chng_Q4_Q1~churn_data$target, main="Change Transaction Count (Q4 over Q1)"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

boxplot(churn_data$Total_Trans_Ct~churn_data$target, main="Total Transaction Count (Last 12 months)"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL )

# Customers who churned usually don't use too much the card

boxplot(churn_data$Avg_Utilization_Ratio~churn_data$target, main="Average Card Utilization Ratio"
        ,col=c("lightblue","orange"),names = c("0 (no)","1 (yes)"),xlab = "IsChurned?", ylab = NULL)



#Qualitative variables

# Women have more probability to churn
CrossTable(churn_data$target, churn_data$Gender,prop.r=TRUE, prop.c=FALSE, prop.t =FALSE, prop.chisq = FALSE)

# Graduate and High school level have more likelihood than the average of 16% of churn
CrossTable(churn_data$target, churn_data$Education_Level,prop.r=TRUE, prop.c=FALSE, prop.t = FALSE, prop.chisq = FALSE)

# Customers who is married and single have more likelihood to churn but also have more people on this status
CrossTable(churn_data$target, churn_data$Marital_Status,prop.r=TRUE, prop.c=FALSE, prop.t = TRUE, prop.chisq = FALSE)

# Customers who ear specially less than 40k have  big chance of churn
CrossTable(churn_data$target, churn_data$Income_Category,prop.r=TRUE, prop.c=FALSE, prop.t = FALSE, prop.chisq = FALSE)

# Customer who have Blue Card is more likely to churn but also there are more than 90% of customers
# that use blue card 
CrossTable(churn_data$target, churn_data$Card_Category,prop.r=TRUE, prop.c=FALSE, prop.t = FALSE, prop.chisq = FALSE)

