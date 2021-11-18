
setwd('C:\\Users\\dsbolanos\\OneDrive - Universidad Rafael Landivar\\Cursos URL\\Analisis de Datos Virtual')

#data de titanic separada
titanic_test<-read.csv("test.csv")
titanic_test$Survived <- NA
titanic_train<-read.csv("train.csv")
complete_data <- rbind(titanic_train, titanic_test)

#verificamos data vacia
colSums(is.na(complete_data))
colSums(complete_data=='')
sapply(complete_data, function(x) length(unique(x)))

## Llenamos datos faltantes
complete_data$Embarked[complete_data$Embarked==""] <- "S"
complete_data$Age[is.na(complete_data$Age)] <- median(complete_data$Age,na.rm=T)



library(dplyr)
# Quitando la cabina ya que le faltan bastantes registors, no usaremos Passangerid, ticket o name
titanic_data <- complete_data %>% select(-c(Cabin, PassengerId, Ticket, Name))

## convertimos "Survived","Pclass","Sex","Embarked" a factors para separarlos
for (i in c("Survived","Pclass","Sex","Embarked")){
  titanic_data[,i]=as.factor(titanic_data[,i])
}

head(titanic_data)
titanic_data<-na.omit(titanic_data)
## dummy data frame nos ayuda a separar columnas factorizadas en columnas separadas segun sus niveles
install.packages("dummies")
library(dummies)
titanic_data <- dummy.data.frame(titanic_data, names=c("Pclass","Sex","Embarked"), sep="_")

#Separamos la data en train y test

set.seed(123)
trainingRowIndex <- sample(1:nrow(titanic_data), 0.8*nrow(titanic_data))  
dtrain <- titanic_data[trainingRowIndex, ]  
dtest  <- titanic_data[-trainingRowIndex, ]  
nrow(dtrain)
nrow(dtest)

#creamos el modelo de regresion
model <- glm(Survived ~.,family=binomial(link='logit'),data=dtrain)
summary(model)

#usamos predict para predecir con la data de test
result <- predict(model,newdata=dtest,type='response')
result <-ifelse(result > 0.5,1,0)
result

install.packages("caret")
library(caret)

matriz<-MatrizConfusion(result,dtest)
matriz$table
matriz$overall

#confusionMatrix(data=as.factor(result), reference=test$Survived)

library(ROCR)
predictions <- predict(model, newdata=dtest, type="response")
dtest$Survived[is.na(dtest$Survived)] <- 0
PlotROCRyAUC(predictions,na.omit(dtest$Survived))


####### comparemos esto con Bayes....

library("e1071")
TitanicBayes=naiveBayes(Survived ~., data=dtrain)
resultBayes <- predict(TitanicBayes,newdata=dtest)

matrizBayes<-MatrizConfusion(resultBayes,dtest)
matrizBayes$table
matrizBayes$overall

predictionsBayes <- predict(TitanicBayes, newdata=dtest)
predvec <- ifelse(predictionsBayes=="1", 1, 0)
realvec <- ifelse(dtest$Survived=="1", 1, 0)

#library(ROCR)
PlotROCRyAUC(predvec,realvec)

