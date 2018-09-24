CREATE PROC [dbo].[uspRKGetOpenContractByDate] 
		@intCommodityId INT = NULL, 
		@dtmToDate DATETIME = NULL
AS
SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

DECLARE @strCommodityCode NVARCHAR(max)

SELECT @strCommodityCode = strCommodityCode
FROM tblICCommodity
WHERE intCommodityId = @intCommodityId


SELECT DISTINCT 
	intFutOptTransactionId,
	intOpenContract,
	@strCommodityCode strCommodityCode,
	strInternalTradeNo,
	strLocationName,
	dblContractSize,
	strFutMarketName strFutureMarket,
	strFutureMonth,
	strOptionMonth,
	dblStrike,
	strOptionType,
	strInstrumentType,
	strBrokerAccount,
	strBroker,
	strBuySell strNewBuySell,
	intFutOptTransactionHeaderId 
FROM (
	SELECT ROW_NUMBER() OVER (
				PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC
				) intRowNum,*  FROM(
	--Futures Buy
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Buy' AND FOT.strInstrumentType = 'Futures'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

	UNION
	--Futures Sell
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Futures'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

	UNION
	--Options Buy
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'BUY' AND FOT.strInstrumentType = 'Options'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

	UNION
	--Options Sell
	SELECT 
		FOT.dtmTransactionDate,
		intFutOptTransactionId, 
		intOpenContract,
		FOT.strCommodityCode,
		strInternalTradeNo,
		strLocationName,
		FOT.dblContractSize,
		FOT.strFutMarketName,
		FOT.strFutureMonthYear AS strFutureMonth,
		FOT.strOptionMonthYear AS strOptionMonth,
		dblStrike,
		strOptionType,
		FOT.strInstrumentType,
		FOT.strBrokerageAccount AS strBrokerAccount,
		FOT.strName AS strBroker,
		strBuySell,
		FOTH.intFutOptTransactionHeaderId 
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Options'
		AND convert(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= convert(DATETIME, @dtmToDate) 

)t2 )t3 WHERE t3.intRowNum = 1