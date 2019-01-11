CREATE FUNCTION [dbo].[fnRKGetOpenFutureByDate](
	@intCommodityId INT = NULL
	, @dtmToDate DATETIME = NULL
)
RETURNS @FinalResult TABLE (
	intFutOptTransactionId INT
	, intOpenContract INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblContractSize NUMERIC(24,10)
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblStrike NUMERIC(24,10)
	, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNewBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionHeaderId int
	, ysnPreCrush BIT
	, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS)

AS 
BEGIN

SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

DECLARE @strCommodityCode NVARCHAR(MAX)

SELECT TOP 1 @strCommodityCode = strCommodityCode
FROM tblICCommodity
WHERE intCommodityId = @intCommodityId

INSERT INTO @FinalResult(
	intFutOptTransactionId
	, intOpenContract
	, strCommodityCode
	, strInternalTradeNo
	, strLocationName
	, dblContractSize
	, strFutureMarket
	, strFutureMonth
	, strOptionMonth
	, dblStrike
	, strOptionType
	, strInstrumentType
	, strBrokerAccount
	, strBroker
	, strNewBuySell  
	, intFutOptTransactionHeaderId
	, ysnPreCrush
	, strNotes
	, strBrokerTradeNo
)
SELECT DISTINCT intFutOptTransactionId
	, intOpenContract
	, strCommodityCode
	, strInternalTradeNo
	, strLocationName
	, dblContractSize
	, strFutMarketName strFutureMarket
	, strFutureMonth
	, strOptionMonth
	, dblStrike
	, strOptionType
	, strInstrumentType
	, strBrokerAccount
	, strBroker
	, strNewBuySell = strBuySell 
	, intFutOptTransactionHeaderId
	, ysnPreCrush
	, strNotes
	, strBrokerTradeNo
FROM (
	SELECT ROW_NUMBER() OVER (PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC) intRowNum
		, *
	FROM (
		--Futures Buy
		SELECT FOT.dtmTransactionDate
			, intFutOptTransactionId
			, intOpenContract
			, FOT.strCommodityCode
			, strInternalTradeNo
			, strLocationName
			, FOT.dblContractSize
			, FOT.strFutMarketName
			, FOT.strFutureMonth AS strFutureMonth
			, FOT.strOptionMonthYear AS strOptionMonth
			, dblStrike
			, strOptionType
			, FOT.strInstrumentType
			, FOT.strBrokerageAccount AS strBrokerAccount
			, FOT.strName AS strBroker
			, strBuySell
			, FOTH.intFutOptTransactionHeaderId
			, FOT.intFutureMarketId
			, FOT.intFutureMonthId
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Buy' AND FOT.strInstrumentType = 'Futures'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			
		UNION ALL
		--Futures Sell
		SELECT FOT.dtmTransactionDate
			, intFutOptTransactionId
			, intOpenContract
			, FOT.strCommodityCode
			, strInternalTradeNo
			, strLocationName
			, FOT.dblContractSize
			, FOT.strFutMarketName
			, FOT.strFutureMonth AS strFutureMonth
			, FOT.strOptionMonthYear AS strOptionMonth
			, dblStrike
			, strOptionType
			, FOT.strInstrumentType
			, FOT.strBrokerageAccount AS strBrokerAccount
			, FOT.strName AS strBroker
			, strBuySell
			, FOTH.intFutOptTransactionHeaderId
			, FOT.intFutureMarketId
			, FOT.intFutureMonthId
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Futures'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			
		UNION ALL
		--Options Buy
		SELECT FOT.dtmTransactionDate
			, intFutOptTransactionId
			, intOpenContract
			, FOT.strCommodityCode
			, strInternalTradeNo
			, strLocationName
			, FOT.dblContractSize
			, FOT.strFutMarketName
			, FOT.strFutureMonth AS strFutureMonth
			, FOT.strOptionMonthYear AS strOptionMonth
			, dblStrike
			, strOptionType
			, FOT.strInstrumentType
			, FOT.strBrokerageAccount AS strBrokerAccount
			, FOT.strName AS strBroker
			, strBuySell
			, FOTH.intFutOptTransactionHeaderId
			, FOT.intFutureMarketId
			, FOT.intFutureMonthId
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'BUY' AND FOT.strInstrumentType = 'Options'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				
		UNION ALL
		--Options Sell
		SELECT FOT.dtmTransactionDate
			, intFutOptTransactionId
			, intOpenContract
			, FOT.strCommodityCode
			, strInternalTradeNo
			, strLocationName
			, FOT.dblContractSize
			, FOT.strFutMarketName
			, FOT.strFutureMonth AS strFutureMonth
			, FOT.strOptionMonthYear AS strOptionMonth
			, dblStrike
			, strOptionType
			, FOT.strInstrumentType
			, FOT.strBrokerageAccount AS strBrokerAccount
			, FOT.strName AS strBroker
			, strBuySell
			, FOTH.intFutOptTransactionHeaderId
			, FOT.intFutureMarketId
			, FOT.intFutureMonthId
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Options'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
	) t2
)t3 WHERE t3.intRowNum = 1


RETURN
END