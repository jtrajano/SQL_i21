CREATE PROCEDURE [dbo].[uspRKGetFutures360UnRealizedPnLReport]
	   @instrument NVARCHAR(100)				
	, @commodity NVARCHAR(100)							
	, @future_market NVARCHAR(100)					
	, @include_expired_months BIT								
	, @broker NVARCHAR(100)								
	, @brokerage_account NVARCHAR(100)					
	, @future_month NVARCHAR(100)				
	, @buy_or_sell NVARCHAR(10)								
	, @book NVARCHAR(200)									
	, @sub_book NVARCHAR(200) 									
	, @realized_from_date NVARCHAR(50) 				
	, @realized_to_date NVARCHAR(50)					
	, @date_format NVARCHAR(50)					
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @ErrMsg NVARCHAR(MAX);

--============================================================================================================
-- Translation of string values to id values.

DECLARE 
  @intCommodityId INT = NULL
, @ysnExpired BIT = @include_expired_months
, @intFutureMarketId INT = NULL
, @intEntityId INT = NULL
, @intBrokerageAccountId INT = NULL
, @intFutureMonthId INT = NULL
, @strBuySell NVARCHAR(10) = @buy_or_sell
, @intBookId INT = NULL 
, @intSubBookId INT = NULL
, @intSelectedInstrumentTypeId INT = NULL
, @dtmFromDate DATETIME = ''
, @dtmToDate DATETIME = ''
, @strFutureMonthLetter NVARCHAR(10) = ''
, @intFutureMonthYear INT = NULL

	
	SELECT @intCommodityId = intCommodityId FROM tblICCommodity WHERE strCommodityCode = @commodity
	SELECT @intBookId = intBookId FROM tblCTBook WHERE strBook = @book
	SELECT @intSubBookId = intSubBookId FROM tblCTSubBook WHERE strSubBook = @sub_book
	SELECT @intFutureMarketId = intFutureMarketId FROM tblRKFutureMarket WHERE strFutMarketName = @future_market

	IF (ISNULL(@future_month, '') != '')
	BEGIN 
		SELECT @strFutureMonthLetter = SUBSTRING(@future_month, 5, 1)
		SELECT @intFutureMonthYear = CONVERT(INT, SUBSTRING(@future_month, 8, 2))

		SELECT	@intFutureMonthId = intFutureMonthId FROM tblRKFuturesMonth 
		WHERE	intFutureMarketId = @intFutureMarketId 
		AND		strSymbol = @strFutureMonthLetter 
		AND		intYear = @intFutureMonthYear
	END

	SELECT @intEntityId = intEntityId FROM tblEMEntity 
	WHERE strName = @broker
	AND intEntityId IN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Futures Broker')
	SELECT @intBrokerageAccountId = intBrokerageAccountId FROM tblRKBrokerageAccount WHERE strAccountNumber = @brokerage_account AND intEntityId = @intEntityId

	SELECT @intSelectedInstrumentTypeId = CASE WHEN @instrument = 'Exchange Traded' THEN 1
											   WHEN @instrument = 'OTC' THEN 2
											   WHEN @instrument = 'OTC - Others' THEN 3 END

--============================================================================================================
-- Translation of date format to be accepted by SQL date formatting

	IF @date_format = 'dd/MM/yyyy'
	BEGIN
		DECLARE @dummyDate NVARCHAR(50)

		IF @realized_from_date IS NOT NULL
		BEGIN 
			SELECT  @dummyDate = SUBSTRING(@realized_from_date, 4, 2) + '/' -- Month
							+ LEFT(@realized_from_date, 2) + '/' -- Day
							+ SUBSTRING(@realized_from_date, 7, 13)
						
			SELECT @dtmFromDate = CAST(@dummyDate AS DATETIME)
		END
		
		IF @realized_to_date IS NOT NULL
		BEGIN
			SELECT  @dummyDate = SUBSTRING(@realized_to_date, 4, 2) + '/' -- Month
							+ LEFT(@realized_to_date, 2) + '/' -- Day
							+ SUBSTRING(@realized_to_date, 7, 13)

			SELECT @dtmToDate = CAST(@dummyDate AS DATETIME)
		END
	END
	ELSE
	BEGIN
		SELECT @dtmFromDate = @realized_from_date
		SELECT @dtmToDate = @realized_to_date
	END
	
--============================================================================================================
-- Generation of records.
IF OBJECT_ID('tempdb..#UnrealizedSettlePrice') IS NOT NULL
	DROP TABLE #UnrealizedSettlePrice
IF OBJECT_ID('tempdb..#UnrealizedData') IS NOT NULL
	DROP TABLE #UnrealizedData

SET @dtmFromDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromDate, 110), 110)
SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(@dtmToDate, GETDATE()), 110), 110)

IF ISNULL(@intCommodityId, 0) = 0
BEGIN
	SET @intCommodityId = NULL
END
IF ISNULL(@intFutureMarketId, 0) = 0
BEGIN
	SET @intFutureMarketId = NULL
END
IF ISNULL(@intEntityId, 0) = 0
BEGIN
	SET @intEntityId = NULL
END
IF ISNULL(@intBrokerageAccountId, 0) = 0
BEGIN
	SET @intBrokerageAccountId = NULL
END
IF ISNULL(@intFutureMonthId, 0) = 0
BEGIN
	SET @intFutureMonthId = NULL
END
IF ISNULL(@intBookId, 0) = 0
BEGIN
	SET @intBookId = NULL
END
IF ISNULL(@intSubBookId, 0) = 0
BEGIN
	SET @intSubBookId = NULL
END

SELECT *
INTO #UnrealizedSettlePrice
FROM (
	SELECT dblLastSettle
		, p.intFutureMarketId
		, pm.intFutureMonthId
		, dtmPriceDate
		, ROW_NUMBER() OVER (PARTITION BY p.intFutureMarketId, pm.intFutureMonthId ORDER BY dtmPriceDate DESC) intRowNum
	FROM tblRKFuturesSettlementPrice p
	INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
	WHERE CONVERT(NVARCHAR, dtmPriceDate, 111) <= CONVERT(NVARCHAR, @dtmToDate, 111)
) t WHERE intRowNum = 1

SELECT CONVERT(INT, DENSE_RANK() OVER (ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth))) RowNum
	, strMonthOrder = strFutureMarket + ' - ' + strFutureMonth + ' - ' + strBroker
	, intFutOptTransactionId
	, GrossPnL dblGrossPnL
	, dblLong
	, dblShort
	, dblFutCommission = - ABS(dblFutCommission)
	, strFutureMarket
	, strFutureMonth
	, dtmTradeDate
	, strInternalTradeNo
	, strBroker
	, strBrokerAccount
	, strBook
	, strSubBook
	, strSalespersonId
	, strCommodityCode
	, strLocationName
	, Long1 dblLong1
	, Sell1 dblSell1
	, dblNet dblNet
	, dblActual
	, dblClosing
	, dblPrice
	, dblContractSize
	, dblFutCommission1 = - ABS(dblFutCommission1)
	, dblMatchLong = MatchLong
	, dblMatchShort = MatchShort
	, dblNetPnL = GrossPnL - ABS(dblFutCommission)
	, intFutureMarketId
	, intFutureMonthId
	, dblOriginalQty
	, intFutOptTransactionHeaderId
	, intCommodityId
	, ysnExpired
	, dblInitialMargin = 0.0
	, LongWaitedPrice = LongWaitedPrice / CASE WHEN ISNULL(dblLongTotalLotByMonth, 0) = 0 THEN 1 ELSE dblLongTotalLotByMonth END
	, ShortWaitedPrice = ShortWaitedPrice / CASE WHEN ISNULL(dblShortTotalLotByMonth, 0) = 0 THEN 1 ELSE dblShortTotalLotByMonth END
	, intSelectedInstrumentTypeId
INTO #UnrealizedData
FROM (
	SELECT *
		, GrossPnL = GrossPnL1 * (dblClosing - dblPrice)
		, dblFutCommission = - dblFutCommission2
		, dblShortTotalLotByMonth = SUM(dblShort) OVER (PARTITION BY intFutureMonthId, strBroker)
		, dblLongTotalLotByMonth = SUM(dblLong) OVER (PARTITION BY intFutureMonthId, strBroker)
		, LongWaitedPrice = (dblLong * dblPrice)
		, ShortWaitedPrice = (dblShort * dblPrice)
	FROM (
		SELECT GrossPnL1 = (ISNULL(Long1, 0) - ISNULL(Sell1, 0)) * dblContractSize / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
			, dblLong = ISNULL(Long1, 0)
			, dblShort = ISNULL(Sell1, 0)
			, dblFutCommission2 = CASE WHEN dblFutCommission1 = 0 THEN 0 ELSE ((ISNULL(Long1, 0) - ISNULL(Sell1, 0)) * - dblFutCommission1) END
			, dblNet = ISNULL(Long1, 0) - ISNULL(Sell1, 0)
			, *
		FROM (
			SELECT intFutOptTransactionId
				, ot.strFutureMarket
				, ot.strFutureMonth
				, ot.intFutureMonthId
				, ot.intCommodityId
				, ot.intFutureMarketId
				, dtmTradeDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ot.dtmFilledDate, 110), 110)
				, ot.strInternalTradeNo
				, ot.strBroker
				, ot.strBrokerAccount
				, ot.strBook
				, ot.strSubBook
				, ot.strSalespersonId
				, ot.strCommodityCode
				, ot.strLocationName
				, dblOriginalQty = ot.dblOpenContract
				, Long1 = ISNULL(CASE WHEN ot.strNewBuySell = 'Buy' THEN ISNULL(ot.dblOpenContract, 0) ELSE NULL END, 0)
				, Sell1 = ISNULL(CASE WHEN ot.strNewBuySell = 'Sell' THEN ABS(ISNULL(ot.dblOpenContract, 0)) ELSE NULL END, 0)
				, dblNet1 = ot.dblOpenContract
				, dblActual = ot.dblPrice
				, dblPrice = ISNULL(ot.dblPrice, 0)
				, ot.dblContractSize
				, intConcurrencyId = 0
				, dblFutCommission1 = ISNULL((SELECT TOP 1 (CASE WHEN bc.intFuturesRateType = 1 THEN 0 ELSE ISNULL(bc.dblFutCommission, 0) / CASE WHEN cur.ysnSubCurrency = 1 THEN cur.intCent ELSE 1 END END)
											FROM tblRKBrokerageCommission bc
											LEFT JOIN tblSMCurrency cur ON cur.intCurrencyID = bc.intFutCurrencyId
											WHERE bc.intFutureMarketId = ot.intFutureMarketId
												AND bc.intBrokerageAccountId = ot.intBrokerageAccountId AND @dtmToDate BETWEEN bc.dtmEffectiveDate AND ISNULL(bc.dtmEndDate, GETDATE())), 0)
				--, MatchLong = ISNULL((SELECT SUM(dblMatchQty)
				--						FROM tblRKMatchFuturesPSDetail psd
				--						JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
				--						WHERE psd.intLFutOptTransactionId = ot.intFutOptTransactionId
				--							AND h.strType = 'Realize' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0)
				--, MatchShort = ISNULL((SELECT SUM(dblMatchQty)
				--						FROM tblRKMatchFuturesPSDetail psd
				--						JOIN tblRKMatchFuturesPSHeader h ON psd.intMatchFuturesPSHeaderId = h.intMatchFuturesPSHeaderId
				--						WHERE psd.intSFutOptTransactionId = ot.intFutOptTransactionId
				--							AND h.strType = 'Realize' AND CONVERT(DATETIME, CONVERT(VARCHAR(10), h.dtmMatchDate, 110), 110) <= @dtmToDate), 0)
				, MatchLong = CASE WHEN strInstrumentType = 'Buy' THEN 0 ELSE dblMatchContract END
				, MatchShort = CASE WHEN strInstrumentType = 'Sell' THEN 0 ELSE dblMatchContract END
				, intCurrencyId = c.intCurrencyID
				, c.intCent
				, c.ysnSubCurrency
				, intFutOptTransactionHeaderId
				, ot.ysnExpired
				, ComCent = c.intCent
				, ComSubCurrency = c.ysnSubCurrency
				, dblClosing = ISNULL(dblLastSettle, 0)
				, intSelectedInstrumentTypeId
			FROM fnRKGetOpenFutureByDate (@intCommodityId, @dtmFromDate, @dtmToDate, 1) ot
			--JOIN tblRKFuturesMonth om ON om.intFutureMonthId = ot.intFutureMonthId AND ot.intInstrumentTypeId = 1
			--JOIN tblRKBrokerageAccount acc ON acc.intBrokerageAccountId = ot.intBrokerageAccountId
			--JOIN tblICCommodity icc ON icc.intCommodityId = ot.intCommodityId
			--JOIN tblSMCompanyLocation sl ON sl.intCompanyLocationId = ot.intLocationId
			--JOIN tblEMEntity sp ON sp.intEntityId = ot.intTraderId
			--JOIN tblEMEntity e ON e.intEntityId = ot.intEntityId
			--JOIN tblRKFutureMarket fm ON ot.intFutureMarketId = fm.intFutureMarketId
			JOIN tblSMCurrency c ON c.intCurrencyID = ot.intCurrencyId
			LEFT JOIN #UnrealizedSettlePrice t ON t.intFutureMarketId = ot.intFutureMarketId AND t.intFutureMonthId = ot.intFutureMonthId
			LEFT JOIN tblCTBook cb ON cb.intBookId = ot.intBookId
			LEFT JOIN tblCTSubBook csb ON csb.intSubBookId = ot.intSubBookId
			WHERE ot.intSelectedInstrumentTypeId = @intSelectedInstrumentTypeId
				AND ISNULL(ot.intCommodityId, 0) = ISNULL(@intCommodityId, ISNULL(ot.intCommodityId, 0))
				AND ISNULL(ot.intFutureMarketId, 0) = ISNULL(@intFutureMarketId, ISNULL(ot.intFutureMarketId, 0))
				AND ISNULL(ot.intBookId, 0) = ISNULL(@intBookId, ISNULL(ot.intBookId, 0))
				AND ISNULL(ot.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ot.intSubBookId, 0))
				AND ISNULL(ot.intEntityId, 0) = ISNULL(@intEntityId, ISNULL(ot.intEntityId, 0))
				AND ISNULL(ot.intBrokerageAccountId, 0) = ISNULL(@intBrokerageAccountId, ISNULL(ot.intBrokerageAccountId, 0))
				AND ISNULL(ot.intFutureMonthId, 0) = ISNULL(@intFutureMonthId, ISNULL(ot.intFutureMonthId, 0))
				AND ot.strNewBuySell = ISNULL(@strBuySell, ot.strNewBuySell)
				AND ot.intInstrumentTypeId = 1
		) t1
	) t1
) t1
WHERE (dblLong <> 0 OR dblShort <> 0)
ORDER BY RowNum ASC

;
WITH
result_tbl
AS
(
SELECT 
	  strFutureMarket [Market]
	, ud.strFutureMonth [Month/Year]
	, [Trade Date] = CASE WHEN @date_format = 'dd/MM/yyyy' THEN CONVERT(VARCHAR, dtmTradeDate, 103) ELSE  CONVERT(VARCHAR, dtmTradeDate, 101) END
	, strInternalTradeNo [Trade No.]
	, strBroker [Broker]
	, strBrokerAccount [Broker Account]
	, strBook [Book]
	, strSubBook [Sub-Book]
	, strSalespersonId [Trader]
	, strCommodityCode [Commodity]
	, strLocationName [Location]
	, dblLong [Long]
	, dblShort [Short]
	, dblNet [Net]
	, dblOriginalQty [Original Qty.]
	, dblActual [Actual]
	, dblClosing [Closing]
	, dblGrossPnL [Gross PnL]
	, dblFutCommission [Commission]
	, dblNetPnL [Net PnL]
	, [Variation] = dblNet * (ISNULL(dbo.fnRKGetVariationMargin(intFutOptTransactionId, @dtmToDate, dtmTradeDate), 0.0) * dblContractSize)
	, RANK() OVER (ORDER BY dtmTradeDate DESC, strFutureMarket, ud.strInternalTradeNo) AS [Sort Order]
FROM #UnrealizedData ud	
JOIN tblRKFuturesMonth fm ON ud.intFutureMonthId = fm.intFutureMonthId
WHERE ud.ysnExpired = CASE WHEN @ysnExpired = 1 THEN ud.ysnExpired ELSE 0 END
)

SELECT 
	  [Market]
	, [Month/Year]
	, [Trade Date]
	, [Trade No.]
	, [Broker]
	, [Broker Account]
	, [Book]
	, [Sub-Book]
	, [Trader]
	, [Commodity]
	, [Location]
	, [Long]
	, [Short]
	, [Net]
	, [Original Qty.]
	, [Actual]
	, [Closing]
	, [Gross PnL]
	, [Commission]
	, [Net PnL]
	, [Variation]
FROM 
(
SELECT * FROM result_tbl
UNION ALL
SELECT 
	  NULL [Market]
	, NULL [Month/Year]
	, NULL [Trade Date]
	, NULL [Trade No.]
	, NULL [Broker]
	, NULL [Broker Account]
	, NULL [Book]
	, NULL [Sub-Book]
	, NULL [Trader]
	, NULL [Commodity]
	, NULL [Location]
	, SUM([Long])
	, SUM([Short])
	, SUM([Net])
	, NULL [Original Qty.]
	, NULL [Actual]
	, NULL [Closing]
	, SUM([Gross PnL])
	, SUM([Commission])
	, SUM([Net PnL])
	, SUM([Variation])
	, [Sort Order] = 9999999999
FROM result_tbl
) t
ORDER BY [Sort Order]

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH