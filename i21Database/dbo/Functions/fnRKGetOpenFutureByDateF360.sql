CREATE FUNCTION [dbo].[fnRKGetOpenFutureByDateF360](
	@intCommodityId INT = NULL
	, @dtmFromDate DATE = NULL
	, @dtmToDate DATE = NULL
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
	, dblMatchContract NUMERIC(18, 6)
	, dblCommission NUMERIC(18, 6))


AS 

BEGIN
	--SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	--SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)

	DECLARE @strCommodityCode NVARCHAR(MAX)
		, @ysnDisableHistoricalDerivative BIT = 0
		, @strReportByDate NVARCHAR(50) = NULL

	SELECT TOP 1 @strCommodityCode = strCommodityCode
	FROM tblICCommodity
	WHERE intCommodityId = @intCommodityId

	SELECT TOP 1 @ysnDisableHistoricalDerivative = ISNULL(ysnDisableHistoricalDerivative, 0)
		, @strReportByDate = strReportByDate FROM tblRKCompanyPreference

	-- @strReportByDate - Default to Filled Date
	IF (ISNULL(@strReportByDate, '') = '')
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
	, ExcludedDerivatives 
	AS (
		SELECT DISTINCT intFutOptTransactionId 
		FROM 
		(	SELECT intFutOptTransactionId
			FROM tblRKOptionsPnSExercisedAssigned

			UNION ALL
			SELECT intFutOptTransactionId 
			FROM tblRKOptionsPnSExpired
		) t
	)
	, FilteredDerivatives 
	AS (
		SELECT intFutOptTransactionId
			, FOT.intInstrumentTypeId
		FROM tblRKFutOptTransactionHeader FOTH
		INNER JOIN tblRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
		WHERE FOT.intInstrumentTypeId IN (1,2) 
		AND FOT.strStatus = 'Filled'
		AND (  
				(@strReportByDate = 'Batch Date' 
				AND CAST(FOT.dtmTransactionDate AS DATE) >= @dtmFromDate
				AND CAST(FOT.dtmTransactionDate AS DATE) <= @dtmToDate)
				OR
				(@strReportByDate = 'Create Date' 
				AND CAST(FOT.dtmCreateDateTime AS DATE) >= @dtmFromDate
				AND CAST(FOT.dtmCreateDateTime AS DATE) <= @dtmToDate)
				OR 
				(@strReportByDate = 'Filled Date' 
				AND CAST(FOT.dtmFilledDate AS DATE) >= @dtmFromDate
				AND CAST(FOT.dtmFilledDate AS DATE) <= @dtmToDate)
			)
		AND FOT.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM ExcludedDerivatives)
	)
	, DerivativeHistory
	AS (
	
		SELECT t.* 
			--, dblOpenContract = t.dblNewNoOfLots - ISNULL(mc.dblMatchContract, 0)
			, dblMatchContract = ISNULL(mc.dblMatchContract, 0) 
			, ysnFiltered = CASE WHEN ISNULL(filtered.intFutOptTransactionId, 0) <> 0 
						THEN CAST(1 AS BIT) 
						ELSE CAST(0 AS BIT) 
						END
		FROM 
		(
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
				, History.intFutOptTransactionHistoryId
				, History.intFutOptTransactionId
				--, History.*
			FROM vyuRKGetFutOptTransactionHistory History
			WHERE ((@ysnDisableHistoricalDerivative = 0
							AND 
							(  (@strReportByDate = 'Create Date'
									AND CAST(History.dtmCreateDateTime AS DATE) >= @dtmFromDate
									AND CAST(History.dtmCreateDateTime AS DATE) <= @dtmToDate)
								OR
								(@strReportByDate = 'Batch Date'
									AND CAST(History.dtmTransactionDate AS DATE) >= @dtmFromDate
									AND CAST(History.dtmTransactionDate AS DATE) <= @dtmToDate)
								OR 
								(@strReportByDate = 'Filled Date'
									AND CAST(History.dtmFilledDate AS DATE) >= @dtmFromDate
									AND CAST(History.dtmFilledDate AS DATE) <= @dtmToDate)
							))
						OR @ysnDisableHistoricalDerivative = 1
					)
		) t 
		LEFT JOIN MatchDerivatives mc ON mc.intFutOptTransactionId = t.intFutOptTransactionId
		LEFT JOIN FilteredDerivatives filtered
			ON filtered.intFutOptTransactionId = t.intFutOptTransactionId
		WHERE t.intRowNum = 1
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
		, dblCommission
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
		, dblCommission
	FROM (
		SELECT *
		FROM (
			--Futures Buy & Sell
			SELECT dtmTransactionDate = CASE WHEN @ysnDisableHistoricalDerivative = 0 AND @strReportByDate = 'Create Date'
											THEN ISNULL(History.dtmCreateDateTime, FOT.dtmTransactionDate)
											ELSE ISNULL(History.dtmTransactionDate, FOT.dtmTransactionDate)
											END
				, FOT.intFutOptTransactionId
				, dblOpenContract = ISNULL(History.dblNewNoOfLots - HistoryId.dblMatchContract, 0)
				, FOT.intCommodityId
				, strCommodityCode = commodity.strCommodityCode
				, FOT.strInternalTradeNo
				, FOT.intLocationId
				, strLocationName = CL.strLocationName
				, dblContractSize = ISNULL(History.dblContractSize, 0)
				, FOT.intFutureMarketId
				, strFutureMarket = FM.strFutMarketName
				, FOT.intFutureMonthId
				, strFutureMonth = FMonth.strFutureMonth
				, FOT.intOptionMonthId
				, strOptionMonth = OM.strOptionMonth
				, FOT.dblStrike
				, FOT.dblPrice
				, FOT.strOptionType
				, FOT.intSelectedInstrumentTypeId
				, FOT.intInstrumentTypeId
				, strInstrumentType = CASE FOT.intInstrumentTypeId 
										WHEN 1 THEN N'Futures'
										WHEN 2 THEN N'Options'
										WHEN 3 THEN N'Spot'
										WHEN 4 THEN N'Forward'
										WHEN 5 THEN N'Swap'
										ELSE ''
									END COLLATE Latin1_General_CI_AS
				, FOT.intBrokerageAccountId
				, strBrokerAccount = BRACC.strAccountNumber
				, strBroker = E.strName
				, FOT.strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.strBrokerTradeNo
				, strNotes = FOT.strReference
				, FOT.ysnPreCrush
				, ysnExpired = FMonth.ysnExpired
				, intBookId = History.intBookId
				, strBook = History.strBook COLLATE Latin1_General_CI_AS
				, intSubBookId = History.intSubBookId
				, strSubBook = History.strSubBook COLLATE Latin1_General_CI_AS
				, FOT.intEntityId
				, FOT.intCurrencyId
				, FOT.intRollingMonthId
				, strRollingMonth = RMonth.strFutureMonth
				, strName = E.strName
				, FOT.dtmFilledDate
				, FOT.intTraderId
				, strSalespersonId = SP.strName
				, dblMatchContract
				, FOT.dblCommission
			FROM tblRKFutOptTransaction FOT -- vyuRKFutOptTransaction FOT
			INNER JOIN tblRKFutOptTransactionHeader FOTH ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			INNER JOIN DerivativeHistory HistoryId
				ON HistoryId.intFutOptTransactionId = FOT.intFutOptTransactionId
				AND HistoryId.ysnFiltered = 1
			INNER JOIN vyuRKGetFutOptTransactionHistory History
				ON HistoryId.intFutOptTransactionHistoryId = History.intFutOptTransactionHistoryId
			LEFT JOIN tblICCommodity commodity
				ON commodity.intCommodityId = FOT.intCommodityId
			LEFT JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = FOT.intLocationId
			LEFT JOIN tblRKFutureMarket FM
				ON FM.intFutureMarketId = FOT.intFutureMarketId
			LEFT JOIN tblRKFuturesMonth FMonth
				ON FMonth.intFutureMonthId = FOT.intFutureMonthId
			LEFT JOIN tblRKFuturesMonth AS RMonth 
				ON FOT.intRollingMonthId = RMonth.intFutureMonthId
			LEFT JOIN tblRKOptionsMonth AS OM 
				ON OM.intOptionMonthId = FOT.intOptionMonthId							
			LEFT JOIN tblRKBrokerageAccount AS BRACC 
				ON BRACC.intBrokerageAccountId = FOT.intBrokerageAccountId
			LEFT JOIN tblEMEntity E
				ON E.intEntityId = FOT.intEntityId
			LEFT JOIN tblEMEntity SP
				ON SP.intEntityId = FOT.intTraderId
			WHERE FOT.intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM FilteredDerivatives filtered WHERE filtered.intInstrumentTypeId = 1)
			
			UNION ALL
			--Options Buy & Sell
			SELECT dtmTransactionDate = CASE WHEN @ysnDisableHistoricalDerivative = 0 AND @strReportByDate = 'Create Date'
											THEN ISNULL(History.dtmCreateDateTime, FOT.dtmTransactionDate)
											ELSE ISNULL(History.dtmTransactionDate, FOT.dtmTransactionDate)
											END 
				, FOT.intFutOptTransactionId
				, dblOpenContract = ISNULL(History.dblNewNoOfLots - HistoryId.dblMatchContract, 0)
				, FOT.intCommodityId
				, strCommodityCode = commodity.strCommodityCode
				, FOT.strInternalTradeNo
				, FOT.intLocationId
				, strLocationName = CL.strLocationName
				, dblContractSize = ISNULL(History.dblContractSize, 0)
				, FOT.intFutureMarketId
				, strFutureMarket = FM.strFutMarketName
				, FOT.intFutureMonthId
				, strFutureMonth = FMonth.strFutureMonth
				, FOT.intOptionMonthId
				, strOptionMonth = OM.strOptionMonth
				, FOT.dblStrike
				, FOT.dblPrice
				, FOT.strOptionType
				, FOT.intSelectedInstrumentTypeId
				, FOT.intInstrumentTypeId
				, strInstrumentType = CASE FOT.intInstrumentTypeId 
										WHEN 1 THEN N'Futures'
										WHEN 2 THEN N'Options'
										WHEN 3 THEN N'Spot'
										WHEN 4 THEN N'Forward'
										WHEN 5 THEN N'Swap'
										ELSE ''
									END COLLATE Latin1_General_CI_AS
				, FOT.intBrokerageAccountId
				, strBrokerAccount = BRACC.strAccountNumber
				, strBroker = E.strName
				, strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.strBrokerTradeNo
				, strNotes = FOT.strReference
				, FOT.ysnPreCrush
				, ysnExpired = FMonth.ysnExpired
				, intBookId = History.intBookId 
				, strBook = History.strBook COLLATE Latin1_General_CI_AS
				, intSubBookId = History.intSubBookId
				, strSubBook = History.strSubBook COLLATE Latin1_General_CI_AS
				, FOT.intEntityId
				, FOT.intCurrencyId
				, FOT.intRollingMonthId
				, strRollingMonth = RMonth.strFutureMonth
				, strName = E.strName
				, FOT.dtmFilledDate
				, FOT.intTraderId
				, strSalespersonId = SP.strName
				, dblMatchContract
				, FOT.dblCommission
			FROM tblRKFutOptTransaction FOT --vyuRKFutOptTransaction FOT 
			INNER JOIN tblRKFutOptTransactionHeader FOTH ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			INNER JOIN DerivativeHistory HistoryId
				ON HistoryId.intFutOptTransactionId = FOT.intFutOptTransactionId
				AND HistoryId.ysnFiltered = 1
			INNER JOIN vyuRKGetFutOptTransactionHistory History
				ON HistoryId.intFutOptTransactionHistoryId = History.intFutOptTransactionHistoryId
			LEFT JOIN tblICCommodity commodity
				ON commodity.intCommodityId = FOT.intCommodityId
			LEFT JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = FOT.intLocationId
			LEFT JOIN tblRKFutureMarket FM
				ON FM.intFutureMarketId = FOT.intFutureMarketId
			LEFT JOIN tblRKFuturesMonth FMonth
				ON FMonth.intFutureMonthId = FOT.intFutureMonthId
			LEFT JOIN tblRKFuturesMonth AS RMonth 
				ON FOT.intRollingMonthId = RMonth.intFutureMonthId
			LEFT JOIN tblRKOptionsMonth AS OM 
				ON OM.intOptionMonthId = FOT.intOptionMonthId							
			LEFT JOIN tblRKBrokerageAccount AS BRACC 
				ON BRACC.intBrokerageAccountId = FOT.intBrokerageAccountId
			LEFT JOIN tblEMEntity E
				ON E.intEntityId = FOT.intEntityId
			LEFT JOIN tblEMEntity SP
				ON SP.intEntityId = FOT.intTraderId
			WHERE FOT.intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM FilteredDerivatives filtered WHERE filtered.intInstrumentTypeId = 2)


			UNION ALL
			-- Deleted Derivatives but with values prior to As Of Date
			SELECT dtmTransactionDate = CASE WHEN @ysnDisableHistoricalDerivative = 1 AND @strReportByDate = 'Create Date'
											THEN History.dtmCreateDateTime
											ELSE History.dtmTransactionDate
											END
				, History.intFutOptTransactionId
				, dblOpenContract = History.dblNewNoOfLots - HistoryId.dblMatchContract -- History.dblOpenContract
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
				, History.dblCommission

			FROM DerivativeHistory HistoryId
			INNER JOIN vyuRKGetFutOptTransactionHistory History
				ON HistoryId.intFutOptTransactionHistoryId = History.intFutOptTransactionHistoryId
			WHERE HistoryId.ysnFiltered = 0
			AND @ysnDisableHistoricalDerivative = 0
			AND strStatus = 'Filled'
				AND (  
						(@strReportByDate = 'Batch Date' 
						AND CAST(dtmTransactionDate AS DATE) >= @dtmFromDate
						AND CAST(dtmTransactionDate AS DATE) <= @dtmToDate)
						OR
						(@strReportByDate = 'Create Date' 
						AND CAST(dtmCreateDateTime AS DATE) >= @dtmFromDate
						AND CAST(dtmCreateDateTime AS DATE) <= @dtmToDate)
						OR 
						(@strReportByDate = 'Filled Date' 
						AND CAST(dtmFilledDate AS DATE) >= @dtmFromDate
						AND CAST(dtmFilledDate AS DATE) <= @dtmToDate)
					) 
		) t2
	)t3 

	RETURN
END