CREATE PROCEDURE [dbo].[uspRKSummaryPnL]
	@dtmFromDate DATETIME
	, @dtmToDate DATETIME
	, @intCommodityId INT = NULL
	, @ysnExpired BIT
	, @intFutureMarketId INT = NULL
	, @intEntityId INT = NULL
	, @intBrokerageAccountId INT = NULL
	, @intFutureMonthId INT = NULL
	, @strBuySell NVARCHAR(10) = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @intSelectedInstrumentTypeId INT = NULL

AS

BEGIN
	SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(@dtmToDate, getdate()), 110), 110)

	DECLARE @UnRelaized AS TABLE (intFutOptTransactionId INT
		, dblGrossPnL NUMERIC(24, 10)
		, dblLong NUMERIC(24, 10)
		, dblShort NUMERIC(24, 10)
		, dblFutCommission NUMERIC(24, 10)
		, strFutMarketName NVARCHAR(100)
		, strFutureMonth NVARCHAR(100)
		, dtmTradeDate DATETIME
		, strInternalTradeNo NVARCHAR(100)
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intEntityId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBook NVARCHAR(100)
		, strSubBook NVARCHAR(100)
		, strSalespersonId NVARCHAR(100)
		, strCommodityCode NVARCHAR(100)
		, strLocationName NVARCHAR(100)
		, dblLong1 INT
		, dblSell1 INT
		, dblNet INT
		, dblActual NUMERIC(24, 10)
		, dblClosing NUMERIC(24, 10)
		, dblPrice NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, dblFutCommission1 NUMERIC(24, 10)
		, dblMatchLong NUMERIC(24, 10)
		, dblMatchShort NUMERIC(24, 10)
		, dblNetPnL NUMERIC(24, 10)
		, intFutureMarketId INT
		, intFutureMonthId INT
		, dblOriginalQty NUMERIC(24, 10)
		, intFutOptTransactionHeaderId INT
		, strMonthOrder NVARCHAR(100)
		, RowNum INT
		, intCommodityId INT
		, ysnExpired BIT
		, dblVariationMargin NUMERIC(24, 10)
		, dblInitialMargin NUMERIC(24, 10)
		, LongWaitedPrice NUMERIC(24, 10)
		, ShortWaitedPrice NUMERIC(24, 10)
		, intSelectedInstrumentTypeId INT)
	
	DECLARE @Relaized AS TABLE (dblGrossPnL NUMERIC(24, 10)
		, intMatchFuturesPSHeaderId INT
		, intMatchFuturesPSDetailId INT
		, intFutOptTransactionId INT
		, intLFutOptTransactionId INT
		, intSFutOptTransactionId INT
		, dblMatchQty NUMERIC(24, 10)
		, dtmLTransDate DATETIME
		, dtmSTransDate DATETIME
		, dblLPrice NUMERIC(24, 10)
		, dblSPrice NUMERIC(24, 10)
		, strLBrokerTradeNo NVARCHAR(100)
		, strSBrokerTradeNo NVARCHAR(100)
		, dblContractSize NUMERIC(24, 10)
		, dblFutCommission NUMERIC(24, 10)
		, strFutMarketName NVARCHAR(100)
		, strFutureMonth NVARCHAR(100)
		, intMatchNo INT
		, dtmMatchDate DATETIME
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(100)
		, strLocationName NVARCHAR(100)
		, dblNetPL NUMERIC(24, 10)
		, intFutureMarketId INT
		, strMonthOrder NVARCHAR(100)
		, RowNum INT
		, intCommodityId INT
		, ysnExpired BIT
		, intFutureMonthId INT
		, strLInternalTradeNo NVARCHAR(100)
		, strSInternalTradeNo NVARCHAR(100)
		, strLRollingMonth NVARCHAR(100)
		, strSRollingMonth NVARCHAR(100)
		, intLFutOptTransactionHeaderId INT
		, intSFutOptTransactionHeaderId INT
		, strBook NVARCHAR(100)
		, strSubBook NVARCHAR(100)
		, dblClosing NUMERIC(24, 10)
		, intSelectedInstrumentTypeId INT)

	INSERT INTO @UnRelaized (RowNum
		, strMonthOrder
		, intFutOptTransactionId
		, dblGrossPnL
		, dblLong
		, dblShort
		, dblFutCommission
		, strFutMarketName
		, strFutureMonth
		, dtmTradeDate
		, strInternalTradeNo
		, strName
		, intEntityId
		, strAccountNumber
		, strBook
		, strSubBook
		, strSalespersonId
		, strCommodityCode
		, strLocationName
		, dblLong1
		, dblSell1
		, dblNet
		, dblActual
		, dblClosing
		, dblPrice
		, dblContractSize
		, dblFutCommission1
		, dblMatchLong
		, dblMatchShort
		, dblNetPnL
		, intFutureMarketId
		, intFutureMonthId
		, dblOriginalQty
		, intFutOptTransactionHeaderId
		, intCommodityId
		, ysnExpired
		, dblVariationMargin
		, dblInitialMargin
		, LongWaitedPrice
		, ShortWaitedPrice
		, intSelectedInstrumentTypeId)
	EXEC uspRKUnrealizedPnL @dtmFromDate = @dtmFromDate
		, @dtmToDate = @dtmToDate
		, @intCommodityId = @intCommodityId
		, @ysnExpired = @ysnExpired
		, @intFutureMarketId = @intFutureMarketId
		, @intEntityId = @intEntityId
		, @intBrokerageAccountId = @intBrokerageAccountId
		, @intFutureMonthId = @intFutureMonthId
		, @strBuySell = @strBuySell
		, @intBookId = @intBookId
		, @intSubBookId = @intSubBookId
		, @intSelectedInstrumentTypeId = @intSelectedInstrumentTypeId
	
	INSERT INTO @Relaized (RowNum
		, strMonthOrder
		, dblNetPL
		, dblGrossPnL
		, intMatchFuturesPSHeaderId
		, intMatchFuturesPSDetailId
		, intFutOptTransactionId
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, dblMatchQty
		, dtmLTransDate
		, dtmSTransDate
		, dblLPrice
		, dblSPrice
		, strLBrokerTradeNo
		, strSBrokerTradeNo
		, dblContractSize
		, dblFutCommission
		, strFutMarketName
		, strFutureMonth
		, intMatchNo
		, dtmMatchDate
		, strName
		, strAccountNumber
		, strCommodityCode
		, strLocationName
		, intFutureMarketId
		, intCommodityId
		, ysnExpired
		, intFutureMonthId
		, strLInternalTradeNo
		, strSInternalTradeNo
		, strLRollingMonth
		, strSRollingMonth
		, intLFutOptTransactionHeaderId
		, intSFutOptTransactionHeaderId
		, strBook
		, strSubBook
		, intSelectedInstrumentTypeId)
	EXEC uspRKRealizedPnL @dtmFromDate = @dtmFromDate
		, @dtmToDate = @dtmToDate
		, @intCommodityId = @intCommodityId
		, @ysnExpired = @ysnExpired
		, @intFutureMarketId = @intFutureMarketId
		, @intEntityId = @intEntityId
		, @intBrokerageAccountId = @intBrokerageAccountId
		, @intFutureMonthId = @intFutureMonthId
		, @strBuySell = @strBuySell
		, @intBookId = @intBookId
		, @intSubBookId = @intSubBookId
		, @intSelectedInstrumentTypeId = @intSelectedInstrumentTypeId
	
	SELECT * INTO #TempSettlementPrice
	FROM (
		SELECT dblLastSettle
			, p.intFutureMarketId
			, pm.intFutureMonthId
			, dtmPriceDate
			, ROW_NUMBER() OVER (PARTITION BY p.intFutureMarketId, pm.intFutureMonthId ORDER BY CONVERT(NVARCHAR, dtmPriceDate, 111) DESC) intRowNum
		FROM tblRKFuturesSettlementPrice p
		INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
		WHERE CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmToDate, 111)
	) t WHERE intRowNum = 1
	
	UPDATE r
	SET r.dblClosing = t.dblLastSettle
	FROM @Relaized r
	LEFT JOIN #TempSettlementPrice t ON t.intFutureMarketId = r.intFutureMarketId AND r.intFutureMonthId = t.intFutureMonthId
	
	DECLARE @Summary AS TABLE (intFutureMarketId INT
		, intFutureMonthId INT
		, strFutMarketName NVARCHAR(100)
		, strFutureMonth NVARCHAR(100)
		, dblLongContracts NUMERIC(24, 10)
		, dblLongAvgPrice NUMERIC(24, 10)
		, dblShortContracts NUMERIC(24, 10)
		, dblShortAvgPrice NUMERIC(24, 10)
		, dblNet NUMERIC(24, 10)
		, dblUnrealized NUMERIC(24, 10)
		, dblClosing NUMERIC(24, 10)
		, dblFutCommission NUMERIC(24, 10)
		, dblPrice NUMERIC(24, 10)
		, dblRealized NUMERIC(24, 10)
		, dblVariationMargin NUMERIC(24, 10)
		, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblTotal NUMERIC(24, 10)
		, ysnExpired BIT
		, dtmTradeDate DATETIME
		, strBook NVARCHAR(50)
		, strSubBook NVARCHAR(50))
	
	INSERT INTO @Summary (intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, dblLongContracts
		, dblLongAvgPrice
		, dblShortContracts
		, dblShortAvgPrice
		, dblNet
		, dblUnrealized
		, dblClosing
		, dblFutCommission
		, dblPrice
		, dblRealized
		, dblVariationMargin
		, strName
		, strAccountNumber
		, dblTotal
		, ysnExpired
		, dtmTradeDate
		, strBook
		, strSubBook)
	SELECT intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, dblLongContracts = ISNULL(dblLongContracts, 0)
		, dblLongAvgPrice
		, dblShortContracts = ISNULL(dblShortContracts, 0)
		, dblShortAvgPrice
		, dblNet = ISNULL(dblNet, 0)
		, dblUnrealized
		, dblClosing
		, dblFutCommission
		, dblPrice
		, dblRealized
		, dblVariationMargin
		, strName
		, strAccountNumber
		, dblTotal = dblUnrealized + dblRealized
		, ysnExpired
		, dtmTradeDate
		, strBook
		, strSubBook
	FROM (
		SELECT intFutureMarketId
			, intFutureMonthId
			, strFutMarketName
			, strFutureMonth
			, dblLongContracts = SUM(ISNULL(dblLong, 0))
			, dblLongAvgPrice = SUM(LongWaitedPrice)
			, dblShortContracts = SUM(ISNULL(dblShort, 0))
			, dblShortAvgPrice = SUM(ShortWaitedPrice)
			, dblNet = SUM(ISNULL(dblLong, 0)) - SUM(ISNULL(dblShort, 0))
			--RM-3330
			--, dblUnrealized = ISNULL(SUM(dblNetPnL), 0)
			, dblUnrealized = ISNULL(SUM(dblGrossPnL), 0)
			, dblClosing = ISNULL(max(dblClosing), 0)
			, dblFutCommission = ISNULL(SUM(dblFutCommission), 0)
			, dblPrice = ISNULL(SUM(dblPrice), 0)
			, dblRealized = ISNULL(SUM(dblGrossPnLRealized), 0)
			, dblVariationMargin = ISNULL(SUM(dblVariationMargin), 0)
			, strName
			, strAccountNumber
			, ysnExpired
			, dtmTradeDate
			, strBook
			, strSubBook
		FROM (
			SELECT dblGrossPnL
				, dblGrossPnLRealized = 0
				, LongWaitedPrice
				, dblLong
				, dblShort
				, ShortWaitedPrice
				, dblFutCommission
				, dblNet
				, intFutOptTransactionId
				, strFutMarketName
				, strFutureMonth
				, intFutureMonthId
				, intCommodityId
				, intFutureMarketId
				, dtmTradeDate
				, dblClosing
				, dblPrice
				, dblNetPnL
				, dblVariationMargin
				, strName
				, strAccountNumber
				, ysnExpired
				, strBook
				, strSubBook
			FROM @UnRelaized
			
			UNION ALL SELECT 0 AS dblGrossPnL
				, t.dblGrossPnL dblGrossPnLRealized
				, NULL LongWaitedPrice
				, NULL dblLong
				, NULL dblShort
				, NULL ShortWaitedPrice
				, t.dblFutCommission
				, t.dblMatchQty dblNet
				, t.intFutOptTransactionId
				, t.strFutMarketName
				, t.strFutureMonth
				, t.intFutureMonthId
				, t.intCommodityId
				, t.intFutureMarketId
				, t.dtmMatchDate
				, dblClosing
				, dblPrice = t.dblSPrice
				, NULL dblNetPnL
				, NULL dblVariationMargin
				, t.strName
				, t.strAccountNumber
				, ysnExpired = ISNULL(t.ysnExpired, 0)
				, strBook
				, strSubBook
			FROM @Relaized t
		) t
		GROUP BY intFutureMonthId
			, intFutureMarketId
			, strFutMarketName
			, strFutureMonth
			, strName
			, strAccountNumber
			, ysnExpired
			, dtmTradeDate
			, strBook
			, strSubBook
	) t
	
	SELECT intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, dblLongContracts = SUM(dblLongContracts)
		, dblLongAvgPrice = SUM(dblLongAvgPrice)
		, dblShortContracts = SUM(dblShortContracts)
		, dblShortAvgPrice = SUM(dblShortAvgPrice)
		, dblNet = SUM(dblNet)
		, dblUnrealized = SUM(dblUnrealized)
		, dblClosing = MAX(dblClosing)
		, dblFutCommission = SUM(dblFutCommission)
		, dblPrice = SUM(dblPrice)
		, dblRealized = SUM(dblRealized)
		, dblVariationMargin = SUM(dblVariationMargin)
		, strName
		, dblTotal = SUM(dblTotal)
		, dblInitialMargin = SUM(dblInitialMargin)
		, ysnExpired
	FROM (
		SELECT intFutureMarketId
			, intFutureMonthId
			, strFutMarketName
			, strFutureMonth
			, dblLongContracts
			, dblLongAvgPrice
			, dblShortContracts
			, dblShortAvgPrice
			, dblNet
			, dblUnrealized
			, dblClosing
			, dblFutCommission
			, dblPrice
			, dblRealized
			, dblVariationMargin
			, strName
			, dblTotal
			, dblInitialMargin = (CASE WHEN ISNULL(dblPerFutureContract, 0) > 0 THEN dblPerFutureContract * dblNet
									ELSE CASE WHEN dblContractMargin <= dblMinAmount THEN dblMinAmount
											WHEN dblContractMargin >= dblMaxAmount THEN dblMaxAmount
											ELSE dblContractMargin END END)
			, ysnExpired
		FROM (
			SELECT *
				, ((dblNet * ISNULL(dblPrice, 0) * dblContractSize) * dblPercenatage) / 100 AS dblContractMargin
			FROM (
				SELECT DISTINCT t.*
					, fm.dblContractSize
					, dblMinAmount = (SELECT TOP 1 dblMinAmount
									FROM tblRKBrokerageCommission bc
									WHERE bc.intFutureMarketId = fm.intFutureMarketId
										AND bc.intBrokerageAccountId = ba.intBrokerageAccountId
										AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, GETDATE()))
					, dblMaxAmount = (SELECT TOP 1 dblMaxAmount
									FROM tblRKBrokerageCommission bc
									WHERE bc.intFutureMarketId = fm.intFutureMarketId
										AND bc.intBrokerageAccountId = ba.intBrokerageAccountId
										AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, GETDATE()))
					, dblPercenatage = (SELECT TOP 1 dblPercenatage
										FROM tblRKBrokerageCommission bc
										WHERE bc.intFutureMarketId = fm.intFutureMarketId
											AND bc.intBrokerageAccountId = ba.intBrokerageAccountId
											AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, GETDATE()))
					, dblPerFutureContract = (SELECT TOP 1 dblPerFutureContract
											FROM tblRKBrokerageCommission bc
											WHERE bc.intFutureMarketId = fm.intFutureMarketId
												AND bc.intBrokerageAccountId = ba.intBrokerageAccountId
												AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, GETDATE()))
				FROM @Summary t
				JOIN tblRKBrokerageAccount ba ON t.strAccountNumber = ba.strAccountNumber
				JOIN tblEMEntity e ON ba.intEntityId = e.intEntityId AND e.strName = t.strName
				JOIN tblRKFutureMarket fm ON t.intFutureMarketId = fm.intFutureMarketId
				JOIN tblRKBrokerageCommission bc ON bc.intBrokerageAccountId = ba.intBrokerageAccountId
			) t
		) t1
	) t2
	GROUP BY intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, strName
		, ysnExpired
	ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC
END