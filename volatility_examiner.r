# Exploratory analysis
# Playing around with data to figure out pivot points
#
# Jon V

#install.packages("quantmod")
#require("quantmod")

data <- read.csv("~/Sources/COT/all_data.csv", sep=";",header = T)
latest <- tail(data, 100)
Date <- as.Date( latest$date, '%m/%d/%Y')

volatility_long <- data.frame(Date, Delt(latest$com_long, latest$com_long, k=1))
volatility_short <- data.frame(Date, Delt(latest$com_short, latest$com_short, k=1))

latest$volatility_long <- volatility_long$Delt.1.arithmetic
latest$volatility_short <- volatility_short$Delt.1.arithmetic

plot(volatility_long[abs(volatility_long$Delt.1.arithmetic) > 0.1,], type="o", col="blue")
volatility = data.frame(latest$volatility_long, latest$volatility_short)
#barplot(as.matrix(t(volatility)), beside = T, col=c("dark green","red"))

volatility_long[abs(volatility_long$Delt.1.arithmetic) > 0.1,]
volatility_short[abs(volatility_short$Delt.1.arithmetic) > 0.1,]

