CREATE PROCEDURE [dbo].[uspRKRealizedPnL]
	@dtmFromDate DATE
	, @dtmToDate DATE
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
	IF @strBuySell = '0'
	BEGIN
		SET @strBuySell = NULL
	END

	--SET @dtmFromDate = CAST(FLOOR(CAST(@dtmFromDate AS FLOAT)) AS DATETIME)
	--SET @dtmToDate = CAST(FLOOR(CAST(@dtmToDate AS FLOAT)) AS DATETIME)

	SELECT CONVERT(INT, DENSE_RANK() OVER(ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth))) RowNum
		, strMonthOrder = strFutureMarket + ' - ' + strFutureMonth + ' - ' + strName
		, dblNetPL = dblGrossPL + (- ABS(dblFutCommission))
		, dblGrossPL
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
		, strFutureMarket
		, strFutureMonth
		, intMatchNo
		, dtmMatchDate
		, strName
		, strBrokerAccount
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
		, intSelectedInstrumentTypeId
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
					, dblFutCommission = ISNULL(psd.dblFutCommission, 0) 
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
				FROM tblRKMatchFuturesPSHeader psh
				JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
				JOIN fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', GETDATE(), 1) ot ON psd.intLFutOptTransactionId = ot.intFutOptTransactionId
				JOIN tblSMCurrency c ON c.intCurrencyID = ot.intCurrencyId
				JOIN fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', GETDATE(), 1) ot1 ON psd.intSFutOptTransactionId = ot1.intFutOptTransactionId
				WHERE ISNULL(ot.intCommodityId, 0) = ISNULL(@intCommodityId, ISNULL(ot.intCommodityId, 0))
					AND ISNULL(ot.intFutureMarketId, 0) = ISNULL(@intFutureMarketId, ISNULL(ot.intFutureMarketId, 0))
					AND ISNULL(ot.intBookId, 0) = ISNULL(@intBookId, ISNULL(ot.intBookId, 0))
					AND ISNULL(ot.intSubBookId, 0) = ISNULL(@intSubBookId, ISNULL(ot.intSubBookId, 0))
					AND ISNULL(ot.intEntityId, 0) = ISNULL(@intEntityId, ISNULL(ot.intEntityId, 0))
					AND ISNULL(ot.intBrokerageAccountId, 0) = ISNULL(@intBrokerageAccountId, ISNULL(ot.intBrokerageAccountId, 0))
					AND ISNULL(ot.intFutureMonthId, 0) = ISNULL(@intFutureMonthId, ISNULL(ot.intFutureMonthId, 0))
					AND ot.strNewBuySell = ISNULL(@strBuySell, ot.strNewBuySell)
					AND CAST(psh.dtmMatchDate AS DATE) >= @dtmFromDate 
					AND CAST(psh.dtmMatchDate AS DATE) <= @dtmToDate
					AND psh.strType = 'Realize'
					AND ISNULL(ot.ysnExpired, 0) = ISNULL(@ysnExpired, ISNULL(ot.ysnExpired, 0))
					AND ot.intInstrumentTypeId = 1
					AND ISNULL(ot.intSelectedInstrumentTypeId, 0) = ISNULL(@intSelectedInstrumentTypeId, ISNULL(ot.intSelectedInstrumentTypeId, 0))
			) t
		)t1
	)t ORDER BY RowNum ASC
END