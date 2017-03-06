# Exploratory analysis
# Playing around with data to figure out pivot points
#
# Jon V

#install.packages("quantmod")
#require("quantmod")

source("~/Sources/COT/volatility_examiner.r")

allStockData <- new.env()
allFxData <- new.env()

stockTickers <- c("VTI")
fxTickers <- c("EUR/USD")
startDate = as.Date("2008-01-13")
endDate = Sys.Date()

getSymbols(stockTickers, env=allStockData, src="yahoo", from = startDate, to = endDate)
getFX(fxTickers, env=allFxData, from=startDate, to=endDate)

stockData <- allStockData[["VTI"]]
closeData <- stockData[,"VTI.Close"]
fxcloseData <- allFxData[["EURUSD"]]
  
weeklyData <- to.weekly(closeData)
weeklyFxData <- to.weekly(fxcloseData)

volatility <- Delt(weeklyData$closeData.Open, weeklyData$closeData.Close, k=1)*100
volatilityFX <- Delt(weeklyFxData$fxcloseData.Open, weeklyFxData$fxcloseData.Close, k=1)*100
volatilityFX <- data.frame(date=index(volatilityFX), coredata(volatilityFX))
colnames(volatilityFX) = c("Date", "Vol")

volatilityCOT <- cot.volatility()
# we ge the report on Friday but we can act on Sunday 
# +5 days from Tuesday when the report is out
volatilityCOT$Date <-volatilityCOT$Date+5

# remove the days before we have FX data
volatilityCOT <- volatilityCOT[volatilityCOT$Date >= head(volatilityFX$Date)[1],]

# Find the FX days from days we don't have a COT report
noFXDataDays = setdiff(volatilityFX$Date, volatilityCOT$Date)
# you can see the days by as.Date(noFXDataDays)

# Find the COT days from days we don't have a FX report
noCOTDataDays = setdiff(volatilityCOT$Date, volatilityFX$Date)

# remove these dates from the datasets
volatilityCOT <- volatilityCOT[! volatilityCOT$Date %in% noCOTDataDays,]
volatilityFX <- volatilityFX[! volatilityFX$Date %in% noFXDataDays,]

# plot
plot(volatilityCOT, volatilityFX$Vol, type="l")
lines(volatilityFX, type="l", col="red")

# create signal based on COT
volatilityCOT <- volatilityCOT[abs(volatilityCOT$Vol) > 10,]
signalCOT <- data.frame(volatilityCOT$Date, ifelse(volatilityCOT$Vol>=0, 'Sell', 'Buy'))
colnames(signalCOT) = c("Date", "EURO")

tmp <- data.frame()
for (i in 1:nrow(signalCOT)){
  tmp <- ifelse (signalCOT[i,"EURO"] != signalCOT[i+i,"EURO"], 
                 data.frame(signalCOT[i,"Date"], signalCOT[i, "EURO"]), 
}

#signalCOT$EndDate <- ifelse(signalCOT$EURO == tail(signalCOT$EURO, -1), 'Same', tail(signalCOT$Date, -1))
#signalCOT$EndDate <- as.Date(strtoi(signalCOT$EndDate))
#signalCOT$EndDate <- ifelse(signalCOT$EURO == tail(signalCOT$EURO, -2), 'X', "None")

#nSignal <- signalCOT
#nSignal <- ifelse(signalCOT$EURO == tail(signalCOT$EURO, -1), 'Same', tail(signalCOT$Date, -1))

# occurances of COT volatility over 10
#over <- volatilityCOT[abs(volatilityCOT$Vol)>10,]$Date

# find what happened these days in FX
#volatilityFX[volatilityFX$Date %in% over,]

# WRONG Assumption
# Should check that after a COT report changes, there is a reverse in EURUSD
# actually what happens from on COT report change to the other
# That means taking a slice of FXData starting from on COT report to the other
dayFXData <- data.frame(date=index(fxcloseData), coredata(fxcloseData))
colnames(dayFXData) = c("Date", "Vol")  

results <- data.frame()
# Date, Signal, open, close, max, min
for(i in 1:nrow(signalCOT)) {
  FXRange <- dayFXData[dayFXData$Date > signalCOT[i, "Date"] 
            & dayFXData$Date < signalCOT[i+1, "Date"] ,]
  closeVal <- tail(FXRange$Vol, 1)
  results <- rbind(results, data.frame(signalCOT[i,"Date"], signalCOT[i+1,"Date"], FXRange$Vol[1], closeVal,
                                       max(FXRange$Vol), min(FXRange$Vol), 
                                       ifelse(FXRange$Vol[1] < closeVal, "Buy", "Sell"),
                                       signalCOT[i, "EURO"]))
}
colnames(results) = c("From", "To", "Open", "Close", "Max", "Min", "Market", "COT")
results$Pips <-  ifelse(results$Market == results$COT, 
                        abs(results$Close-results$Open)*10000, -abs(results$Close-results$Open)*10000)

fxover <- volatilityFX[abs(volatilityFX$Vol)>2,]$Date
length(intersect(fxover, over))

