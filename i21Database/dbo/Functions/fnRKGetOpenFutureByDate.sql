CREATE FUNCTION [dbo].[fnRKGetOpenFutureByDate](
	@intCommodityId INT = NULL
	, @dtmFromDate DATETIME = NULL
	, @dtmToDate DATETIME = NULL
	, @ysnCrush BIT = 0
)
RETURNS @FinalResult TABLE (intFutOptTransactionId INT
	, dtmTransactionDate DATETIME
	, dblOpenContract NUMERIC(18, 6)
	, intCommodityId INT
	, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intLocationId INT
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblContractSize NUMERIC(24,10)
	, intFutureMarketId INT
	, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOptionMonthId INT
	, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblPrice NUMERIC(24,10)
	, dblStrike NUMERIC(24,10)
	, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSelectedInstrumentTypeId INT
	, intInstrumentTypeId INT
	, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intBrokerageAccountId INT
	, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNewBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intBookId INT
	, strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intSubBookId INT
	, strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intEntityId INT
	, intFutOptTransactionHeaderId int
	, ysnPreCrush BIT
	, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnExpired BIT
	, intCurrencyId INT
	, intRollingMonthId INT
	, strRollingMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dtmFilledDate DATETIME
	, intTraderId INT
	, strSalespersonId NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblMatchContract NUMERIC(18, 6))


AS 

BEGIN
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)

	DECLARE @strCommodityCode NVARCHAR(MAX)
		, @ysnDisableHistoricalDerivative BIT = 0
		, @strReportByDate NVARCHAR(50) = NULL

	SELECT TOP 1 @strCommodityCode = strCommodityCode
	FROM tblICCommodity
	WHERE intCommodityId = @intCommodityId

	SELECT TOP 1 @ysnDisableHistoricalDerivative = ISNULL(ysnDisableHistoricalDerivative, 0)
		, @strReportByDate = strReportByDate FROM tblRKCompanyPreference

	-- @strReportByDate - Default to Filled Date
	IF (@strReportByDate IS NULL)
	BEGIN
		SELECT @strReportByDate = 'Filled Date'
	END

	;WITH MatchDerivatives (
		intFutOptTransactionId
		, strInstrumentType
		, strBuySell
		, dblMatchContract
	)
	AS (
		SELECT *
		FROM dbo.[fnRKGetOpenContractHistory](@dtmFromDate, @dtmToDate)
	)

	INSERT INTO @FinalResult(intFutOptTransactionId
		, dtmTransactionDate
		, dblOpenContract
		, intCommodityId
		, strCommodityCode
		, strInternalTradeNo
		, intLocationId
		, strLocationName
		, dblContractSize
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, intOptionMonthId
		, strOptionMonth
		, dblStrike
		, dblPrice
		, strOptionType
		, intSelectedInstrumentTypeId
		, intInstrumentTypeId
		, strInstrumentType
		, intBrokerageAccountId
		, strBrokerAccount
		, strBroker
		, strNewBuySell  
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, intEntityId
		, intFutOptTransactionHeaderId
		, ysnPreCrush
		, strNotes
		, strBrokerTradeNo
		, ysnExpired
		, intCurrencyId
		, intRollingMonthId
		, strRollingMonth
		, strName
		, dtmFilledDate
		, intTraderId
		, strSalespersonId
		, dblMatchContract
	)
	SELECT DISTINCT intFutOptTransactionId
		, dtmTransactionDate
		, dblOpenContract
		, intCommodityId
		, strCommodityCode
		, strInternalTradeNo
		, intLocationId
		, strLocationName
		, dblContractSize
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, intOptionMonthId
		, strOptionMonth
		, dblStrike
		, dblPrice
		, strOptionType
		, intSelectedInstrumentTypeId
		, intInstrumentTypeId
		, strInstrumentType
		, intBrokerageAccountId
		, strBrokerAccount
		, strBroker
		, strNewBuySell = strBuySell
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, intEntityId
		, intFutOptTransactionHeaderId
		, ysnPreCrush
		, strNotes
		, strBrokerTradeNo
		, ysnExpired
		, intCurrencyId
		, intRollingMonthId
		, strRollingMonth
		, strName
		, dtmFilledDate
		, intTraderId
		, strSalespersonId
		, dblMatchContract
	FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC) intRowNum
			, *
		FROM (
			--Futures Buy & Sell
			SELECT dtmTransactionDate = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dtmTransactionDate
											ELSE 
												CASE WHEN @ysnDisableHistoricalDerivative = 0 AND @strReportByDate = 'Create Date'
													THEN ISNULL(History.dtmCreateDateTime, FOT.dtmTransactionDate)
													ELSE ISNULL(History.dtmTransactionDate, FOT.dtmTransactionDate)
													END 
											END
				, FOT.intFutOptTransactionId
				, dblOpenContract = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblOpenContract
										ELSE ISNULL(History.dblOpenContract, FOT.dblOpenContract) END
				, FOT.intCommodityId
				, FOT.strCommodityCode
				, FOT.strInternalTradeNo
				, FOT.intLocationId
				, FOT.strLocationName
				, dblContractSize = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblContractSize
										ELSE ISNULL(History.dblContractSize, FOT.dblContractSize) END
				, FOT.intFutureMarketId
				, strFutureMarket = FOT.strFutMarketName
				, FOT.intFutureMonthId
				, strFutureMonth = FOT.strFutureMonth
				, FOT.intOptionMonthId
				, strOptionMonth = FOT.strOptionMonthYear
				, FOT.dblStrike
				, FOT.dblPrice
				, FOT.strOptionType
				, FOT.intSelectedInstrumentTypeId
				, FOT.intInstrumentTypeId
				, FOT.strInstrumentType
				, FOT.intBrokerageAccountId
				, FOT.strBrokerageAccount AS strBrokerAccount
				, FOT.strName AS strBroker
				, FOT.strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.strBrokerTradeNo
				, FOT.strNotes
				, FOT.ysnPreCrush
				, FOT.ysnExpired
				, FOT.intBookId
				, FOT.strBook
				, FOT.intSubBookId
				, FOT.strSubBook
				, FOT.intEntityId
				, FOT.intCurrencyId
				, FOT.intRollingMonthId
				, FOT.strRollingMonth
				, FOT.strName
				, FOT.dtmFilledDate
				, FOT.intTraderId
				, FOT.strSalespersonId
				, dblMatchContract
			FROM tblRKFutOptTransactionHeader FOTH
			INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			OUTER APPLY (
				SELECT * FROM (
					SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY History.intFutOptTransactionId 
							ORDER BY History.intFutOptTransactionId, 
								CASE WHEN @ysnDisableHistoricalDerivative = 1 
								THEN History.intFutOptTransactionHistoryId 
								ELSE 
									CASE WHEN @strReportByDate = 'Create Date'
									THEN History.dtmCreateDateTime
									ELSE History.dtmTransactionDate 
									END
								END DESC) 
						, History.*
						, dblOpenContract = History.dblNewNoOfLots - ISNULL(mc.dblMatchContract, 0)
						, dblMatchContract = ISNULL(mc.dblMatchContract, 0)
					FROM vyuRKGetFutOptTransactionHistory History
					LEFT JOIN MatchDerivatives mc ON mc.intFutOptTransactionId = FOT.intFutOptTransactionId
					WHERE History.intFutOptTransactionId = FOT.intFutOptTransactionId
						AND 
							((@ysnDisableHistoricalDerivative = 0
									AND 
									(  (@strReportByDate = 'Create Date'
											AND CAST(FLOOR(CAST(History.dtmCreateDateTime AS FLOAT)) AS DATETIME) >= @dtmFromDate
											AND CAST(FLOOR(CAST(History.dtmCreateDateTime AS FLOAT)) AS DATETIME) <= @dtmToDate)
										OR
										((@strReportByDate = 'Filled Date' OR @strReportByDate = 'Batch Date')
										AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
										AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
									))
							  OR @ysnDisableHistoricalDerivative = 1
							)
				) t WHERE intRowNum = 1
			) History
			WHERE FOT.strInstrumentType = 'Futures'
				AND FOT.strStatus = 'Filled'
				AND (  
						(@strReportByDate = 'Batch Date' 
						AND CAST(FLOOR(CAST(FOT.dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(FOT.dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
						OR
						(@strReportByDate = 'Create Date' 
						AND CAST(FLOOR(CAST(FOT.dtmCreateDateTime AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(FOT.dtmCreateDateTime AS FLOAT)) AS DATETIME) <= @dtmToDate)
						OR 
						(@strReportByDate = 'Filled Date' 
						AND CAST(FLOOR(CAST(FOT.dtmFilledDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(FOT.dtmFilledDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
					)
				AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
				AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			
			UNION ALL
			--Options Buy & Sell
			SELECT dtmTransactionDate = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dtmTransactionDate
											ELSE 
												CASE WHEN @ysnDisableHistoricalDerivative = 0 AND @strReportByDate = 'Create Date'
													THEN ISNULL(History.dtmCreateDateTime, FOT.dtmTransactionDate)
													ELSE ISNULL(History.dtmTransactionDate, FOT.dtmTransactionDate)
													END 
											END
				, FOT.intFutOptTransactionId
				, dblOpenContract = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblOpenContract
										ELSE ISNULL(History.dblOpenContract, FOT.dblOpenContract) END
				, FOT.intCommodityId
				, FOT.strCommodityCode
				, FOT.strInternalTradeNo
				, FOT.intLocationId
				, FOT.strLocationName
				, dblContractSize = CASE WHEN ISNULL(@ysnCrush, 0) = 0 THEN FOT.dblContractSize
										ELSE ISNULL(History.dblContractSize, FOT.dblContractSize) END
				, FOT.intFutureMarketId
				, FOT.strFutMarketName
				, FOT.intFutureMonthId
				, FOT.strFutureMonth AS strFutureMonth
				, FOT.intOptionMonthId
				, FOT.strOptionMonthYear AS strOptionMonth
				, FOT.dblStrike
				, FOT.dblPrice
				, FOT.strOptionType
				, FOT.intSelectedInstrumentTypeId
				, FOT.intInstrumentTypeId
				, FOT.strInstrumentType
				, FOT.intBrokerageAccountId
				, FOT.strBrokerageAccount AS strBrokerAccount
				, FOT.strName AS strBroker
				, strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.strBrokerTradeNo
				, FOT.strNotes
				, FOT.ysnPreCrush
				, FOT.ysnExpired
				, FOT.intBookId
				, FOT.strBook
				, FOT.intSubBookId
				, FOT.strSubBook
				, FOT.intEntityId
				, FOT.intCurrencyId
				, FOT.intRollingMonthId
				, FOT.strRollingMonth
				, FOT.strName
				, FOT.dtmFilledDate
				, FOT.intTraderId
				, FOT.strSalespersonId
				, dblMatchContract
			FROM tblRKFutOptTransactionHeader FOTH
			INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			OUTER APPLY (
				SELECT * FROM (
					SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY History.intFutOptTransactionId 
							ORDER BY History.intFutOptTransactionId, 
								CASE WHEN @ysnDisableHistoricalDerivative = 1 
								THEN History.intFutOptTransactionHistoryId 
								ELSE 
									CASE WHEN @strReportByDate = 'Create Date'
									THEN History.dtmCreateDateTime
									ELSE History.dtmTransactionDate 
									END
								END DESC) 
						, History.*
						, dblOpenContract = History.dblNewNoOfLots - ISNULL(mc.dblMatchContract, 0)
						, dblMatchContract = ISNULL(mc.dblMatchContract, 0)
					FROM vyuRKGetFutOptTransactionHistory History 
					LEFT JOIN MatchDerivatives mc ON mc.intFutOptTransactionId = FOT.intFutOptTransactionId
					WHERE History.intFutOptTransactionId = FOT.intFutOptTransactionId
						AND ((@ysnDisableHistoricalDerivative = 0
									AND 
									(  (@strReportByDate = 'Create Date'
											AND CAST(FLOOR(CAST(History.dtmCreateDateTime AS FLOAT)) AS DATETIME) >= @dtmFromDate
											AND CAST(FLOOR(CAST(History.dtmCreateDateTime AS FLOAT)) AS DATETIME) <= @dtmToDate)
										OR
										((@strReportByDate = 'Filled Date' OR @strReportByDate = 'Batch Date')
										AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
										AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
									))
							  OR @ysnDisableHistoricalDerivative = 1
							)
				) t WHERE intRowNum = 1
			) History
			WHERE FOT.strInstrumentType = 'Options'
				AND FOT.strStatus = 'Filled'
				AND (  
						(@strReportByDate = 'Batch Date' 
						AND CAST(FLOOR(CAST(FOT.dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(FOT.dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
						OR
						(@strReportByDate = 'Create Date' 
						AND CAST(FLOOR(CAST(FOT.dtmCreateDateTime AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(FOT.dtmCreateDateTime AS FLOAT)) AS DATETIME) <= @dtmToDate)
						OR 
						(@strReportByDate = 'Filled Date' 
						AND CAST(FLOOR(CAST(FOT.dtmFilledDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(FOT.dtmFilledDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
					)
				AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
				AND FOT.intFutOptTransactionId NOT IN (SELECT DISTINCT intFutOptTransactionId FROM tblRKOptionsPnSExpired)

			UNION ALL
			-- Deleted Derivatives but with values prior to As Of Date
			SELECT dtmTransactionDate = CASE WHEN @ysnDisableHistoricalDerivative = 1 AND @strReportByDate = 'Create Date'
											THEN History.dtmCreateDateTime
											ELSE History.dtmTransactionDate
											END
				, History.intFutOptTransactionId
				, dblOpenContract = History.dblOpenContract
				, intCommodityId
				, History.strCommodity COLLATE Latin1_General_CI_AS
				, History.strInternalTradeNo COLLATE Latin1_General_CI_AS
				, intLocationId
				, History.strLocationName COLLATE Latin1_General_CI_AS
				, History.dblContractSize
				, intFutureMarketId
				, History.strFutureMarket COLLATE Latin1_General_CI_AS
				, intFutureMonthId
				, History.strFutureMonth COLLATE Latin1_General_CI_AS
				, intOptionMonthId
				, History.strOptionMonth COLLATE Latin1_General_CI_AS
				, History.dblStrike 
				, History.dblPrice
				, History.strOptionType COLLATE Latin1_General_CI_AS
				, intSelectedInstrumentTypeId = CASE WHEN strSelectedInstrumentType = 'Exchange Traded' THEN 1
													WHEN strSelectedInstrumentType = 'OTC' THEN 2
													WHEN strSelectedInstrumentType = 'OTC - Others' THEN 3 END
				, intInstrumentTypeId = CASE WHEN strInstrumentType = 'Futures' THEN 1
											WHEN strInstrumentType = 'Options' THEN 2
											WHEN strInstrumentType = 'Currency Contract' THEN 3 END
				, History.strInstrumentType COLLATE Latin1_General_CI_AS
				, intBrokerId
				, History.strBrokerAccount COLLATE Latin1_General_CI_AS
				, History.strBroker COLLATE Latin1_General_CI_AS
				, strBuySell = History.strNewBuySell  COLLATE Latin1_General_CI_AS
				, intFutOptTransactionHeaderId
				, strBrokerTradeNo COLLATE Latin1_General_CI_AS
				, History.strNotes COLLATE Latin1_General_CI_AS
				, History.ysnPreCrush
				, ysnMonthExpired
				, intBookId
				, History.strBook COLLATE Latin1_General_CI_AS
				, intSubBookId
				, History.strSubBook COLLATE Latin1_General_CI_AS
				, intEntityId
				, intCurrencyId
				, intRollingMonthId
				, strRollingMonth COLLATE Latin1_General_CI_AS
				, strName = History.strBroker COLLATE Latin1_General_CI_AS
				, dtmFilledDate
				, intTraderId
				, History.strSalespersonId COLLATE Latin1_General_CI_AS
				, dblMatchContract
			FROM (
				SELECT *
				FROM (
					SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY History.intFutOptTransactionId 
							ORDER BY History.intFutOptTransactionId, 
								CASE WHEN @ysnDisableHistoricalDerivative = 1 
								THEN History.intFutOptTransactionHistoryId 
								ELSE 
									CASE WHEN @strReportByDate = 'Create Date'
									THEN History.dtmCreateDateTime
									ELSE History.dtmTransactionDate 
									END
								END DESC) 
						, History.*
						, dblOpenContract = History.dblNewNoOfLots - ISNULL(mc.dblMatchContract, 0)
						, dblMatchContract = ISNULL(mc.dblMatchContract, 0)
					FROM vyuRKGetFutOptTransactionHistory History 
					LEFT JOIN MatchDerivatives mc ON mc.intFutOptTransactionId = History.intFutOptTransactionId
					WHERE History.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKFutOptTransaction)
						AND (  (@strReportByDate = 'Create Date'
											AND CAST(FLOOR(CAST(History.dtmCreateDateTime AS FLOAT)) AS DATETIME) >= @dtmFromDate
											AND CAST(FLOOR(CAST(History.dtmCreateDateTime AS FLOAT)) AS DATETIME) <= @dtmToDate)
										OR
										((@strReportByDate = 'Filled Date' OR @strReportByDate = 'Batch Date')
										AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
										AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
									)
						
						AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(History.dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate
				) t WHERE intRowNum = 1
						AND @ysnDisableHistoricalDerivative = 0
			) History
			WHERE ISNULL(@ysnCrush, 0) = 1
				AND strStatus = 'Filled'
				AND (  
						(@strReportByDate = 'Batch Date' 
						AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(dtmTransactionDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
						OR
						(@strReportByDate = 'Create Date' 
						AND CAST(FLOOR(CAST(dtmCreateDateTime AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(dtmCreateDateTime AS FLOAT)) AS DATETIME) <= @dtmToDate)
						OR 
						(@strReportByDate = 'Filled Date' 
						AND CAST(FLOOR(CAST(dtmFilledDate AS FLOAT)) AS DATETIME) >= @dtmFromDate
						AND CAST(FLOOR(CAST(dtmFilledDate AS FLOAT)) AS DATETIME) <= @dtmToDate)
					)
		) t2
	)t3 WHERE t3.intRowNum = 1
	RETURN
END