##### Ejemplo de K means
data("USArrests")      # cargamos un data set de prueba

arrestos <- scale(USArrests) # con la funcion scale ajustamos todo a la media y sd
arrestos <- na.omit(arrestos)
write.csv(arrestos,file='arrestos.csv')
head(arrestos)
head(USArrests)

install.packages("factoextra") #paquete para graficar
library(factoextra) #libreria de paquete instalado

#graficamos la distancia de las 4 variables usando una funcion de "distance matrix"
distancia <- get_dist(arrestos)
fviz_dist(distancia, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))


set.seed(123) #seed permitira fijar un id para generar valores random
clusterk2 <- kmeans(arrestos, 2, nstart = 25)
print(clusterk2)

#visualizacion de asignacion a cluster
clusterk2$cluster
#Tamaño de cada cluster
clusterk2$size
#Centros de los 4 clusters
clusterk2$centers

fviz_cluster(clusterk4, data = arrestos)

clusterk3 <- kmeans(arrestos, 3, nstart = 25)
clusterk4 <- kmeans(arrestos, 4, nstart = 25)
clusterk5 <- kmeans(arrestos, 5, nstart = 25)

grafica1 <- fviz_cluster(clusterk2, geom = "point", data = arrestos) + ggtitle("k = 2")
grafica2 <- fviz_cluster(clusterk3, geom = "point",  data = arrestos) + ggtitle("k = 3")
grafica3 <- fviz_cluster(clusterk4, geom = "point",  data = arrestos) + ggtitle("k = 4")
grafica4 <- fviz_cluster(clusterk5, geom = "point",  data = arrestos) + ggtitle("k = 5")

library(gridExtra)
grid.arrange(grafica1, grafica2, grafica3, grafica4, nrow = 2)

#dibujamos la grafica de wss vs K para ver el K "optimo"
fviz_nbclust(arrestos, kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2)

EstadosCluster4<-as.data.frame(clusterk4$cluster)
arrestrosRaw<-USArrests

tst<-merge(EstadosCluster4,arrestrosRaw,by=0, all=TRUE)

names(tst)[2]<-"clustno"
tst<-subset(tst, select=-c(Row.names))

aggregate(tst,by=list(tst$clustno),FUN=mean)

fviz_cluster(clusterk4, data = arrestos)