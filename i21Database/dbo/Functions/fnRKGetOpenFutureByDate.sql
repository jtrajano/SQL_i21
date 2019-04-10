CREATE FUNCTION [dbo].[fnRKGetOpenFutureByDate](
	@intCommodityId INT = NULL
	, @dtmToDate DATETIME = NULL
	, @ysnCrush BIT = 0
)
RETURNS @FinalResult TABLE (
	intFutOptTransactionId INT
	, dblOpenContract NUMERIC(18, 6)
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
	, dblOpenContract
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
	, dblOpenContract
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
		--Futures Buy & Sell
		SELECT dtmTransactionDate = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dtmTransactionDate
										ELSE History.dtmTransactionDate END
			, FOT.intFutOptTransactionId
			, dblOpenContract = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblOpenContract
									ELSE History.dblOpenContract END
			, FOT.strCommodityCode
			, FOT.strInternalTradeNo
			, FOT.strLocationName
			, dblContractSize = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblContractSize
									ELSE History.dblContractSize END
			, FOT.strFutMarketName
			, FOT.strFutureMonth AS strFutureMonth
			, FOT.strOptionMonthYear AS strOptionMonth
			, FOT.dblStrike
			, FOT.strOptionType
			, FOT.strInstrumentType
			, FOT.strBrokerageAccount AS strBrokerAccount
			, FOT.strName AS strBroker
			, FOT.strBuySell
			, FOTH.intFutOptTransactionHeaderId
			, FOT.intFutureMarketId
			, FOT.intFutureMonthId
			, FOT.strBrokerTradeNo
			, FOT.strNotes
			, FOT.ysnPreCrush
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		OUTER APPLY (
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER (PARTITION BY History.intFutOptTransactionId ORDER BY History.intFutOptTransactionId, History.dtmTransactionDate DESC) intRowNum
					, *
					, dblOpenContract = History.dblNewNoOfContract - ISNULL([dbo].[fnRKGetOpenContractHistory](@dtmToDate, History.intFutOptTransactionId), 0)
				FROM vyuRKGetFutOptTransactionHistory History 
				WHERE History.intFutOptTransactionId = FOT.intFutOptTransactionId
					AND History.dtmTransactionDate <= DATEADD(MILLISECOND, -2, DATEADD(DAY, 1, CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)))
			) t WHERE intRowNum = 1
		) History
		WHERE FOT.strInstrumentType = 'Futures'
			AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dtmTransactionDate
										ELSE History.dtmTransactionDate END, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			
			
		UNION ALL
		--Options Buy & Sell
		SELECT dtmTransactionDate = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dtmTransactionDate
										ELSE History.dtmTransactionDate END
			, FOT.intFutOptTransactionId
			, dblOpenContract = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblOpenContract
									ELSE History.dblOpenContract END
			, FOT.strCommodityCode
			, FOT.strInternalTradeNo
			, FOT.strLocationName
			, dblContractSize = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblContractSize
									ELSE History.dblContractSize END
			, FOT.strFutMarketName
			, FOT.strFutureMonth AS strFutureMonth
			, FOT.strOptionMonthYear AS strOptionMonth
			, FOT.dblStrike
			, FOT.strOptionType
			, FOT.strInstrumentType
			, FOT.strBrokerageAccount AS strBrokerAccount
			, FOT.strName AS strBroker
			, strBuySell
			, FOTH.intFutOptTransactionHeaderId
			, FOT.intFutureMarketId
			, FOT.intFutureMonthId
			, FOT.strBrokerTradeNo
			, FOT.strNotes
			, FOT.ysnPreCrush
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		OUTER APPLY (
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER (PARTITION BY History.intFutOptTransactionId ORDER BY History.intFutOptTransactionId, History.dtmTransactionDate DESC) intRowNum
					, *
					, dblOpenContract = History.dblNewNoOfContract - ISNULL([dbo].[fnRKGetOpenContractHistory](@dtmToDate, History.intFutOptTransactionId), 0)
				FROM vyuRKGetFutOptTransactionHistory History 
				WHERE History.intFutOptTransactionId = FOT.intFutOptTransactionId
					AND History.dtmTransactionDate <= DATEADD(MILLISECOND, -2, DATEADD(DAY, 1, CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)))
			) t WHERE intRowNum = 1
		) History
		WHERE FOT.strInstrumentType = 'Options'
			AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dtmTransactionDate
										ELSE History.dtmTransactionDate END, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				

		UNION ALL
		-- Deleted Derivatives but with values prior to As Of Date
		SELECT History.dtmTransactionDate
			, History.intFutOptTransactionId
			, dblOpenContract = History.dblOpenContract
			, History.strCommodity
			, History.strInternalTradeNo
			, History.strLocationName
			, History.dblContractSize
			, History.strFutureMarket
			, History.strFutureMonth
			, History.strOptionMonth
			, History.dblStrike
			, History.strOptionType
			, History.strInstrumentType
			, History.strBrokerAccount
			, History.strBroker
			, strBuySell = History.strNewBuySell
			, intFutOptTransactionHeaderId
			, intFutureMarketId
			, intFutureMonthId
			, strBrokerTradeNo
			, History.strNotes
			, History.ysnPreCrush
		FROM (
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER (PARTITION BY History.intFutOptTransactionId ORDER BY History.intFutOptTransactionId, History.dtmTransactionDate DESC) intRowNum
					, *
					, dblOpenContract = History.dblNewNoOfContract - ISNULL([dbo].[fnRKGetOpenContractHistory](@dtmToDate, History.intFutOptTransactionId), 0)
				FROM vyuRKGetFutOptTransactionHistory History 
				WHERE History.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKFutOptTransaction)
					AND History.dtmTransactionDate <= DATEADD(MILLISECOND, -2, DATEADD(DAY, 1, CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)))
			) t WHERE intRowNum = 1
		) History
		WHERE ISNULL(@ysnCrush, 0) = 1
	) t2
)t3 WHERE t3.intRowNum = 1


RETURN
END