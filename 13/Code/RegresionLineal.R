setwd("C:\\Users\\dsbolanos\\OneDrive - Universidad Rafael Landivar\\Cursos URL\\Analisis de Datos\\R")

library("readxl")

ageandheight <- read_excel("ageandheight.xls", sheet = "Hoja2") #Upload the data
lmHeight = lm(height~age, data = ageandheight) #Create the linear regression
summary(lmHeight) #Review the results

cor(ageandheight$age,ageandheight$height)
cor(ageandheight$age,ageandheight$height)^2 #R cuadrado

# Estatura = 64.92843 + 0.63528 * Edad
lmHeight2 = lm(height~age + no_siblings, data = ageandheight) #Create a linear regression with two variables
summary(lmHeight2) #Review the results

plot(height~age, data=ageandheight) 
abline(lm(height~age, data = ageandheight)) 

persona<-data.frame(24,3)
names(persona)[1]<-"age"
names(persona)[2]<-"no_siblings"

predict(lmHeight, newdata=persona)
predict(lmHeight2, newdata=persona)

#ejemplo con cars

head(cars)
data(cars)

###Analisis de variables

#scatterplot
scatter.smooth(x=cars$speed, y=cars$dist, main="Dist ~ Speed")  # scatterplot

#boxplots
par(mfrow=c(1, 2))  # divide grafico en 2 columnas
boxplot(cars$speed, main="Speed", sub=paste("Outlier rows: ", boxplot.stats(cars$speed)$out))  
boxplot(cars$dist, main="Distance", sub=paste("Outlier rows: ", boxplot.stats(cars$dist)$out)) 

#densityplots
library(e1071)
par(mfrow=c(1, 2))  # divide grafico en 2 columnas
plot(density(cars$speed), main="Density Plot: Speed", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(cars$speed), 2)))  # density plot para 'speed'
polygon(density(cars$speed), col="red")
plot(density(cars$dist), main="Density Plot: Distance", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(cars$dist), 2)))  # density plot para 'dist'
polygon(density(cars$dist), col="red")

#correlacion
cor(cars$speed, cars$dist)  # calcular velocidad y distancia en correlacion

#modelo de regresion lineal
lmcarros <- lm(dist ~ speed, data=cars)
summary(lmcarros)

carro<-data.frame(13)
names(carro)[1]<-"speed"

predict(lmcarros,carro)

#Creamos un modelo datos de train y test
set.seed(90)  

trainingRowIndex <- sample(1:nrow(cars), 0.8*nrow(cars))  
trainingData <- cars[trainingRowIndex, ]  
testData  <- cars[-trainingRowIndex, ]  

#creamos el modelo lineal
lmMod <- lm(dist ~ speed, data=trainingData)  
distPred <- predict(lmMod, testData)  # predecimos usanto test data

#Revisamos el modelo creado
summary (lmMod)  # model summary

actuals_preds <- data.frame(cbind(actuals=testData$dist, predicteds=distPred))  # make actuals_predicteds dataframe.
correlation_accuracy <- cor(actuals_preds)
correlation_accuracy

#calculamos el MAD
mad <- mean(abs((actuals_preds$predicteds - actuals_preds$actuals)))  
mad

#ploteamos el modelo con intervalos
par(mfrow=c(1, 1)) 

library(ggplot2)
ggplot(cars, aes(x=speed, y=dist)) + 
  geom_point(color='#2980B9', size = 4) + 
  geom_smooth(method=lm, color='#2C3E50')

#vemos las predicciones y sus intervalos
actuals_preds_intervalos <- data.frame(cbind(actuals_preds,predict(lmMod, newdata = testData, interval = 'confidence')))
actuals_preds_intervalos$fit<-NULL
actuals_preds_intervalos

#### Ejemplo de prediccion de stock_index_price

Year <- c(2017,2017,2017,2017,2017,2017,2017,2017,2017,2017,2017,2017,2016,2016,2016,2016,2016,2016,2016,2016,2016,2016,2016,2016)
Month <- c(12, 11,10,9,8,7,6,5,4,3,2,1,12,11,10,9,8,7,6,5,4,3,2,1)
Interest_Rate <- c(2.75,2.5,2.5,2.5,2.5,2.5,2.5,2.25,2.25,2.25,2,2,2,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75,1.75)
Unemployment_Rate <- c(5.3,5.3,5.3,5.3,5.4,5.6,5.5,5.5,5.5,5.6,5.7,5.9,6,5.9,5.8,6.1,6.2,6.1,6.1,6.1,5.9,6.2,6.2,6.1)
Stock_Index_Price <- c(1464,1394,1357,1293,1256,1254,1234,1195,1159,1167,1130,1075,1047,965,943,958,971,949,884,866,876,822,704,719)        

plot(x=Interest_Rate, y=Stock_Index_Price) 
plot(x=Unemployment_Rate, y=Stock_Index_Price) 

model <- lm(Stock_Index_Price ~ Interest_Rate + Unemployment_Rate)
summary(model)
