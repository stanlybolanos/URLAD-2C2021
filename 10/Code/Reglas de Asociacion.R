
setwd("C:\\Users\\dsbolanos\\OneDrive - Universidad Rafael Landivar\\Cursos URL\\Analisis de Datos Virtual\\11")

# Instalamos los paquetes
 install.packages('arules')
 library('arules')

 #leemos el csv
 txn <- read.transactions ("Compras.csv",rm.duplicates = FALSE,format="single",sep=",",cols=c(1,2))

txn@itemInfo
image(txn)

#definimos las reglas
basket_rules <- apriori(txn,parameter=list(sup=0.5,conf=0.9,target="rules"))
#vemos que reglas son validas
inspect(basket_rules)

#############################################################################
#dataset Groceries
data(Groceries)
Groceries
Groceries@itemInfo
typeof(Groceries)

#definimos reglas
rules <- apriori(Groceries, parameter=list(support=0.001, confidence=0.5))
inspect(rules)

#extraemos reglas con confianza =0.8 o mas
subrules <- rules[quality(rules)$confidence > 0.8]
inspect(subrules)

#vemos solo el top 3 con mayor lift
rules_high_lift <- head(sort(rules, by="lift"), 3)
inspect(rules_high_lift)

image(Groceries)
a<-as(subrules,"data.frame")
b<-data.frame(subrules)
#libreria para plotear arules
install.packages("arulesViz")
library("arulesViz")

plot(subrules)
plot(subrules, engine = "plotly") #plot interactivo

#tabla para visualizar reglas
inspectDT(subrules)
inspectDT(rules_high_lift)

#plot grafico
plot(rules_high_lift, method = "graph", engine = "htmlwidget")


##############################################################################
#dataset Admisiones
library(DBI)
library(odbc)
con <- dbConnect(odbc(), Driver = "SQL Server", Server = "localhost", 
                 Database = "Admisiones")

df<- dbGetQuery(con,'
  select *
  from VW_ResultadoCandidato
')

#validamos que soporte es bueno utilizar combinando elementos
table(df$Genero, df$Resultado)
table(df$NombreCarrera,df$Genero,df$Resultado, df$NombreColegio)
df$ID_Candidato = NULL

#definimos reglas
rules <- apriori(df, parameter=list(support=0.01, confidence=0.5, minlen=2))
inspect(rules)

top3rules<-head(sort(rules, by="lift"), 3)
Conf75rules<-rules[quality(rules)$confidence > 0.75]
inspect(top3rules)
inspect(Conf75rules)

inspect(subset(rules, subset=rhs %pin% "Resultado=R"))

plot(top3rules)
plot(top3rules, engine = "plotly") #plot interactivo

#tabla para visualizar reglas
inspectDT(top3rules)
inspectDT(rules_high_lift)

#plot grafico
plot(top3rules, method = "graph", engine = "htmlwidget")

