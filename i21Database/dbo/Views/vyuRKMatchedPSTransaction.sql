CREATE VIEW [dbo].[vyuRKMatchedPSTransaction]

AS

SELECT dblGrossPL = ISNULL(dblGrossPL, 0.00)
	, intMatchFuturesPSHeaderId
	, intMatchFuturesPSDetailId
	, intFutOptTransactionId
	, intLFutOptTransactionId
	, intSFutOptTransactionId
	, dblMatchQty = ISNULL(dblMatchQty, 0.00)
	, intLFutOptTransactionHeaderId
	, intSFutOptTransactionHeaderId
	, dtmLTransDate
	, dtmSTransDate
	, dblLPrice = ISNULL(dblLPrice, 0.00)
	, dblSPrice = ISNULL(dblSPrice, 0.00)
	, strLInternalTradeNo
	, strSInternalTradeNo
	, strLBrokerTradeNo
	, strSBrokerTradeNo
	, dblContractSize = ISNULL(dblContractSize, 0.00)
	, intConcurrencyId
	, dblFutCommission = ISNULL(dblFutCommission, 0.00)
	, intCurrencyId
	, strCurrency
	, intMainCurrencyId
	, strMainCurrency
	, intCent
	, ysnSubCurrency
	, dblNetPL = ISNULL(dblGrossPL, 0.00) -- ISNULL((dblGrossPL + dblFutCommission), 0.00)
	, dtmLFilledDate
	, dtmSFilledDate
	, intLFutureMonthId
	, strLFutureMonth
	, intSFutureMonthId
	, strSFutureMonth
FROM (
	SELECT dblGrossPL = ((dblSPrice - dblLPrice) * dblMatchQty * dblContractSize) / CASE WHEN ysnSubCurrency = 1 THEN intCent ELSE 1 END
		, *
	FROM (
		SELECT psh.intMatchFuturesPSHeaderId
			, psd.intMatchFuturesPSDetailId
			, ot.intFutOptTransactionId
			, psd.intLFutOptTransactionId
			, psd.intSFutOptTransactionId
			, dblMatchQty = ISNULL(psd.dblMatchQty, 0.00)
			, intLFutOptTransactionHeaderId = ot.intFutOptTransactionHeaderId
			, intSFutOptTransactionHeaderId = ot1.intFutOptTransactionHeaderId
			, intLFutureMonthId = ot.intFutureMonthId
			, intSFutureMonthId = ot1.intFutureMonthId
			, strLFutureMonth = LFM.strFutureMonth
			, strSFutureMonth = SFM.strFutureMonth
			, dtmLTransDate = ot.dtmTransactionDate
			, dtmSTransDate = ot1.dtmTransactionDate
			, dtmLFilledDate = ot.dtmFilledDate
			, dtmSFilledDate = ot1.dtmFilledDate
			, dblLPrice = ISNULL(ot.dblPrice, 0.00)
			, dblSPrice = ISNULL(ot1.dblPrice, 0.00)
			, strLInternalTradeNo = ot.strInternalTradeNo
			, strSInternalTradeNo = ot1.strInternalTradeNo
			, strLBrokerTradeNo = ot.strBrokerTradeNo
			, strSBrokerTradeNo = ot1.strBrokerTradeNo
			, dblContractSize = fm.dblContractSize
			, psd.dblFutCommission
			, intCurrencyId = c.intCurrencyID
			, c.strCurrency
			, intMainCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE c.intCurrencyID END
			, strMainCurrency = CASE WHEN c.ysnSubCurrency = 0 THEN c.strCurrency ELSE MainCurrency.strCurrency END
			, c.intCent
			, c.ysnSubCurrency
			, psd.intConcurrencyId
		FROM tblRKMatchFuturesPSHeader psh
		JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
		JOIN tblRKFutOptTransaction ot ON psd.intLFutOptTransactionId = ot.intFutOptTransactionId
		JOIN tblRKFutOptTransaction ot1 ON psd.intSFutOptTransactionId = ot1.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket fm ON ot.intFutureMarketId = fm.intFutureMarketId
		LEFT JOIN tblSMCurrency c ON c.intCurrencyID = fm.intCurrencyId
		LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
		LEFT JOIN tblRKFuturesMonth LFM ON LFM.intFutureMonthId = ot.intFutureMonthId
		LEFT JOIN tblRKFuturesMonth SFM ON SFM.intFutureMonthId = ot1.intFutureMonthId
		LEFT JOIN tblRKBrokerageAccount ba ON ot.intBrokerageAccountId = ba.intBrokerageAccountId AND ot.intInstrumentTypeId IN (1)
	)t
)t1