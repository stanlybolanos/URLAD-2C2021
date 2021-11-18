## ARIMA
library(tseries)
#veamos los datos de Lynx
plot(lynx)

#evaluemos la autocorrelacion
acf(lynx, lag.max = 20) 
pacf(lynx, lag.max = 20)

adf.test(lynx)
adf.test(data)

#auto arima define automaticamente p,d,q
auto.arima(lynx)
arima(lynx)

#habilitamos el parametro trace para ver las iteraciones del modelo
auto.arima(lynx, trace = T)

#deshabilitamos stepwise y approximation para no simplificar el modelo
myar = auto.arima(lynx, stepwise = F, approximation = F)

myar

# Ploteamos vs original
plot(lynx, lwd = 3)
lines(myar$fitted, col = "red")

plot(forecast(myar, h = 3))

#evaluemos accuracy
accuracy(myar)

## Suavizamiento exponencial
library(forecast)

# Using function ets
etsmodel = ets(lynx) 
etsmodel

# Ploteamos vs original
plot(lynx, lwd = 3)
lines(etsmodel$fitted, col = "red")

#comparamos el accuracy
accuracy(etsmodel)

#probamos otro dataset
plot(nottem)
etsmodel = ets(nottem) 
etsmodel

# Ploteamos vs original
plot(nottem, lwd = 3)
lines(etsmodel$fitted, col = "red")

# Poteamos el forecast
plot(forecast(etsmodel, h =12 ))

# Changing the prediction interval
plot(forecast(etsmodel, h = 12, level = 95))

# Manually setting the ets model
etsmodmult = ets(nottem, model ="MZM"); etsmodmult

# Plot as comparison
plot(nottem, lwd = 3)
lines(etsmodmult$fitted, col = "red")


#birth time series

births <- scan("http://robjhyndman.com/tsdldata/data/nybirths.dat")
birthstimeseries <- ts(births, frequency=12, start=c(1946,1))
birthstimeseries
plot(birthstimeseries)

birtharima<-auto.arima(birthstimeseries)
birthets<-ets(birthstimeseries)

accuracy(birtharima)
accuracy(birthets)

plot(forecast(birtharima, h = 12, level = 95))
