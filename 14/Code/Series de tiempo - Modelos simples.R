## Modelos simples
data = rnorm(20, mean =7)
testts = ts(data = data, start = c(2020,4), frequency = 4)
plot(testts)

install.packages('ggplot')
library(ggplot2)


install.packages("forecast", dependencies=TRUE)
library(forecast)

#funcion meanf pronostica en base al promedio simple
meanmodel <- meanf(testts, h=20)

#funcion naive pronostica colocando el mismo valor de la ultima observacion
naivemodel <- naive(testts, h=20)

#drift es una extrapolacion de la primera observacion hasta la ultima hacia el futuro
driftmmodel <- rwf(testts, h=20, drift = T)

#dibujamos las lineas de los 3 pronosticos
plot(meanmodel, plot.conf = F, main = "")
lines(naivemodel$mean, col=123, lwd = 2)
lines(driftmmodel$mean, col='red', lwd = 2)

legend("topleft",lty=1,col=c(4,123,22),
       legend=c("Mean","Naive","Drift"))

adf.test(data)

## Precision y comparasion de modelos
set.seed(95)
mits <- ts(rnorm(400), start = c(1919,1), frequency = 4)
plot(mits)

adf.test(mits)

# la funcion window nos permite dividir un objeto "ts" de un inicio a un fin
mits80p <- window(mits, start = 1919, end = 1999)
plot(mits80p)

# creamos los 3 modelos con el 80 porciento
#library(forecast)
meanmodel <- meanf(mits80p, h=80)
naivemodel <- naive(mits80p, h=80)
driftmodel <- rwf(mits80p, h=80, drift = T)

# Extraemos el resto 20 porciento
mytstest <- window(mits, start = 2000)

accuracy(meanmodel, mytstest)
accuracy(naivemodel, mytstest)
accuracy(driftmodel, mytstest)

## Residual

# generamos nuevamente los datos
set.seed(95)
mits <- ts(rnorm(100), start = (1919))

# Setting up our simple models
#library(forecast)
meanm <- meanf(mits, h=20)
naivem <- naive(mits, h=20)
driftm <- rwf(mits, h=20, drift = T)

# validamos media y varianza de los residuos
#mean
var(meanm$residuals)#esperamos que la varianza este cerca de 1
plot(meanm$residuals)#graficamos la varianza para validar que sea constante
mean(meanm$residuals)#esperamos que la media sea 0 (constante)

#naive
var(na.omit(naivem$residuals))
mean(na.omit(naivem$residuals))

#drift
var(na.omit(driftm$residuals))
mean(na.omit(driftm$residuals))

# evaluamos la distribucion de los residuos...
hist(meanm$residuals)

#...y Autcorrelacion
acf(meanm$residuals)
adf.test(mits)
datatrend <- c(3, 4, 4, 5, 6, 7, 6, 6, 7, 8, 9, 12, 10)
plot(datatrend)
adf.test(datatrend)

