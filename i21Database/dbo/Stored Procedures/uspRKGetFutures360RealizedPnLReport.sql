CREATE PROCEDURE [dbo].[uspRKGetFutures360RealizedPnLReport]
	  @instrument NVARCHAR(100)			
	, @commodity NVARCHAR(100)						
	, @future_market NVARCHAR(100)						
	, @include_expired_months BIT							
	, @broker NVARCHAR(100) 						
	, @brokerage_account NVARCHAR(100)						
	, @future_month NVARCHAR(100)						
	, @buy_or_sell NVARCHAR(10)							
	, @book NVARCHAR(200)									
	, @sub_book NVARCHAR(200) = NULL											
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
IF ISNULL(@intSelectedInstrumentTypeId, 0) = 0
BEGIN
	SET @intSelectedInstrumentTypeId = NULL
END

SET @dtmFromDate = CAST(FLOOR(CAST(@dtmFromDate AS FLOAT)) AS DATETIME)
SET @dtmToDate = CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)

;
WITH 
result_tbl
AS
(
SELECT 
	  strFutureMarket [Market]
	, strFutureMonth [Month/Year]
	, strBook [Book]
	, strSubBook [SubBook]
	, intMatchNo [Match No.]
	, [Match Date] = CASE WHEN @date_format = 'dd/MM/yyyy' THEN CONVERT(VARCHAR, dtmMatchDate, 103) ELSE  CONVERT(VARCHAR, dtmMatchDate, 101) END
	, strLBrokerTradeNo [Long Internal Trade No.]
	, strLRollingMonth [Long Rolling Month]
	, strSBrokerTradeNo [Short Internal Trade No.]
	, strSRollingMonth [Short Rolling Month]
	, dblMatchQty [Match Qty.]
	, strName [Broker]
	, strBrokerAccount [Account]
	, strCommodityCode [Commodity]
	, strLocationName [Location]
	, dblGrossPL [Gross PnL]
	, dblFutCommission [Commission]
	, [Net PnL] = dblGrossPL + (- ABS(dblFutCommission))
	, RANK() OVER (ORDER BY intYear, strSymbol, strFutureMarket, strLBrokerTradeNo) AS [Sort Order]
FROM (
	SELECT * FROM (
		SELECT dblGrossPL1 = ((dblSPrice - dblLPrice) * dblMatchQty * dblContractSize)
			, dblGrossPL= ((dblSPrice - dblLPrice) * dblMatchQty * dblContractSize) / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
			, *
		FROM (
			SELECT psh.intMatchFuturesPSHeaderId
				, psd.intMatchFuturesPSDetailId
				, ot.intFutOptTransactionId
				, psd.intLFutOptTransactionId
				, psd.intSFutOptTransactionId
				, dblMatchQty = ISNULL(psd.dblMatchQty, 0)
				, dtmLTransDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ot.dtmTransactionDate, 110), 110)
				, dtmSTransDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), ot1.dtmTransactionDate, 110), 110)
				, dblLPrice = ISNULL(ot.dblPrice, 0)
				, dblSPrice = ISNULL(ot1.dblPrice, 0)
				, strLBrokerTradeNo = ot.strInternalTradeNo
				, strSBrokerTradeNo = ot1.strInternalTradeNo
				, ot.dblContractSize
				, intConcurrencyId = 0
				, dblFutCommission = CASE WHEN ISNULL(bc.intFuturesRateType, 2) = 2 THEN ISNULL(bc.dblFutCommission, 0) * ISNULL(psd.dblMatchQty, 0) * 2 ELSE ISNULL(bc.dblFutCommission, 0) * ISNULL(psd.dblMatchQty, 0) END
				, ot.strFutureMarket
				, ot.strFutureMonth
				, psh.intMatchNo
				, dtmMatchDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), psh.dtmMatchDate, 110), 110)
				, ot.strName
				, ot.strBrokerAccount
				, ot.strCommodityCode
				, ot.strLocationName
				, ot.intFutureMonthId
				, ot.intCommodityId
				, ot.intFutureMarketId
				, intCurrencyId = c.intCurrencyID
				, c.intCent
				, c.ysnSubCurrency
				, ot.ysnExpired
				, c.intCent ComCent
				, c.ysnSubCurrency ComSubCurrency
				, ot.strInternalTradeNo strLInternalTradeNo
				, ot1.strInternalTradeNo strSInternalTradeNo
				, strLRollingMonth = ot.strRollingMonth
				, strSRollingMonth = ot1.strRollingMonth
				, intLFutOptTransactionHeaderId = ot.intFutOptTransactionHeaderId
				, intSFutOptTransactionHeaderId = ot1.intFutOptTransactionHeaderId
				, ot.strBook
				, ot.strSubBook
				, ot.intInstrumentTypeId
				, ot.intSelectedInstrumentTypeId
				, fm.strSymbol
				, fm.intYear
			FROM tblRKMatchFuturesPSHeader psh
			JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
			JOIN fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', GETDATE(), 1) ot ON psd.intLFutOptTransactionId = ot.intFutOptTransactionId
			JOIN tblSMCurrency c ON c.intCurrencyID = ot.intCurrencyId
			JOIN fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', GETDATE(), 1) ot1 ON psd.intSFutOptTransactionId = ot1.intFutOptTransactionId
			JOIN tblRKBrokerageCommission bc ON bc.intFutureMarketId = psh.intFutureMarketId AND psh.intBrokerageAccountId = bc.intBrokerageAccountId
			JOIN tblRKFuturesMonth fm ON ot.intFutureMonthId = fm.intFutureMonthId
			WHERE ISNULL(ot.intCommodityId, 0) = ISNULL(@intCommodityId, ISNULL(ot.intCommodityId, 0))
				AND ISNULL(ot.intFutureMarketId, 0) = ISNULL(@intFutureMarketId, ISNULL(ot.intFutureMarketId, 0))
				AND ISNULL(ot.intBookId, 0) = ISNULL(@intBookId, ISNULL(ot.intBookId, 0))
				AND ISNULL(ot.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ot.intSubBookId, 0))
				AND ISNULL(ot.intEntityId, 0) = ISNULL(@intEntityId, ISNULL(ot.intEntityId, 0))
				AND ISNULL(ot.intBrokerageAccountId, 0) = ISNULL(@intBrokerageAccountId, ISNULL(ot.intBrokerageAccountId, 0))
				AND ISNULL(ot.intFutureMonthId, 0) = ISNULL(@intFutureMonthId, ISNULL(ot.intFutureMonthId, 0))
				AND ot.strNewBuySell = ISNULL(@strBuySell, ot.strNewBuySell)
				AND CAST(FLOOR(CAST(psh.dtmMatchDate AS FLOAT)) AS DATETIME) >= @dtmFromDate AND CAST(FLOOR(CAST(psh.dtmMatchDate AS FLOAT)) AS DATETIME) <= @dtmToDate
				AND psh.strType = 'Realize'
				AND ISNULL(ot.ysnExpired, 0) = ISNULL(@ysnExpired, ISNULL(ot.ysnExpired, 0))
				AND ot.intInstrumentTypeId = 1
				AND ISNULL(ot.intSelectedInstrumentTypeId, 0) = ISNULL(@intSelectedInstrumentTypeId, ISNULL(ot.intSelectedInstrumentTypeId, 0))
		) t
	)t1
)t 
)

SELECT [Market]
	, [Month/Year]
	, [Book]
	, [SubBook]
	, [Match No.]
	, [Match Date] 
	, [Long Internal Trade No.]
	, [Long Rolling Month]
	, [Short Internal Trade No.]
	, [Short Rolling Month]
	, [Match Qty.]
	, [Broker]
	, [Account]
	, [Commodity]
	, [Location]
	, [Gross PnL]
	, [Commission]
	, [Net PnL] 
	
FROM 
(
SELECT * FROM result_tbl

UNION ALL 

SELECT 
	  NULL [Market]
	, NULL [Month/Year]
	, NULL [Book]
	, NULL [SubBook]
	, NULL [Match No.]
	, NULL [Match Date] 
	, NULL [Long Internal Trade No.]
	, NULL [Long Rolling Month]
	, NULL [Short Internal Trade No.]
	, NULL [Short Rolling Month]
	, NULL [Match Qty.]
	, NULL [Broker]
	, NULL [Account]
	, NULL [Commodity]
	, NULL [Location]
	, SUM([Gross PnL]) [Gross PnL]
	, SUM([Commission]) [Commission]
	, SUM([Net PnL]) [Net PnL]
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