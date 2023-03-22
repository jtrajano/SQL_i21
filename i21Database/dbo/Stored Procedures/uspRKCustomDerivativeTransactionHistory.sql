CREATE PROCEDURE [dbo].[uspRKCustomDerivativeTransactionHistory]
	  @FromDate DATE
	, @ToDate DATE
AS

BEGIN
	IF DATEDIFF(DAY, @FromDate, @ToDate) > 360 -- 12 MONTHS LIMIT
	BEGIN 
		RAISERROR ('DATE RANGE SHOULD NOT EXCEED A RANGE MORE THAN 12 MONTHS.', 16, 1, 'WITH NOWAIT')
		RETURN
	END
	
	SELECT [Row Id] = t.intRowId
		, [Transaction History Id] = t.intFutOptTransactionHistoryId
		, [Transaction Id] = t.intFutOptTransactionId
		, [Transaction Header Id] = t.intFutOptTransactionHeaderId
		, [Transaction Date] = t.dtmTransactionDate
		, [Selected Instrument Type] = t.strSelectedInstrumentType
		, [Instrument Type] = t.strInstrumentType
		, [Future Market Id] = t.intFutureMarketId
		, [Future Market] = t.strFutureMarket
		, [Currency Id] = t.intCurrencyId
		, [Currency] = t.strCurrency
		, [Commodity Id] = t.intCommodityId
		, [Commodity] = t.strCommodity
		, [Entity Id] = t.intEntityId
		, [Broker Id] = t.intBrokerId
		, [Broker] = t.strBroker
		, [Broker Account] = t.strBrokerAccount
		, [Trader] = t.strTrader
		, [Broker Trade No] = t.strBrokerTradeNo
		, [Future Month] = t.strFutureMonth
		, [Option Month] = t.strOptionMonth
		, [Option Type] = t.strOptionType
		, [Strike] = t.dblStrike
		, [Price] = t.dblPrice
		, [Status] = t.strStatus
		, [Filled Date] = t.dtmFilledDate
		, [Old No Of Lots] = t.dblOldNoOfLots
		, [Lot Balance] = t.dblLotBalance
		, [Contract Balance] = t.dblContractBalance
		, [New No Of Lots] = t.dblNewNoOfLots
		, [Screen Name] = t.strScreenName
		, [Old Buy Sell] = t.strOldBuySell
		, [New Buy Sell] = t.strNewBuySell
		, [Internal Trade No] = t.strInternalTradeNo
		, [Location Id] = t.intLocationId
		, [Location Name] = t.strLocationName
		, [Contract Size] = t.dblContractSize
		, [Book Id] = t.intBookId
		, [Book] = t.strBook
		, [SubBook Id] = t.intSubBookId
		, [SubBook] = t.strSubBook
		, [Month Expired] = t.ysnMonthExpired
		, [User Name] = t.strUserName
		, [Action] = t.strAction
		, [Notes] = t.strNotes
		, [Crush] = t.ysnPreCrush
		, [Rolling Month] = t.strRollingMonth
		, [Rolling Month Id] = t.intRollingMonthId
		, [Trader Id] = t.intTraderId
		, [Salesperson Id] = t.strSalespersonId
	FROM vyuRKSearchDerivativeEntryHistory t
	WHERE CAST(t.dtmTransactionDate AS DATE) BETWEEN @FromDate AND @ToDate
END