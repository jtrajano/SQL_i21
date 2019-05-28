﻿CREATE VIEW [dbo].[vyuRKMatchedPSTransaction]

AS

SELECT isnull(dblGrossPL,0.0) as dblGrossPL
	, intMatchFuturesPSHeaderId
	, intMatchFuturesPSDetailId
	, intFutOptTransactionId
	, intLFutOptTransactionId
	, intSFutOptTransactionId
	, isnull(dblMatchQty,0.0) dblMatchQty
	, intLFutOptTransactionHeaderId
	, intSFutOptTransactionHeaderId
	, dtmLTransDate
	, dtmSTransDate
	, isnull(dblLPrice,0.0) as dblLPrice
	, isnull(dblSPrice,0.0) as dblSPrice
	, strLInternalTradeNo
	, strSInternalTradeNo
	, strLBrokerTradeNo
	, strSBrokerTradeNo
	, isnull(dblContractSize,0.0) as dblContractSize
	, intConcurrencyId
	, isnull(dblFutCommission,0.0) as dblFutCommission
	, intCurrencyId
	, strCurrency
	, intMainCurrencyId
	, strMainCurrency
	, intCent
	, ysnSubCurrency
	, isnull((dblGrossPL + dblFutCommission),0.0)  AS dblNetPL 
	, dtmLFilledDate,dtmSFilledDate
FROM (
	SELECT ((dblSPrice - dblLPrice)*dblMatchQty*dblContractSize)/ case when ysnSubCurrency = 1 then intCent else 1 end as dblGrossPL
		, *
	FROM (
		SELECT psh.intMatchFuturesPSHeaderId
			, psd.intMatchFuturesPSDetailId
			, ot.intFutOptTransactionId
			, psd.intLFutOptTransactionId
			, psd.intSFutOptTransactionId
			, isnull(psd.dblMatchQty,0) as dblMatchQty
			, ot.intFutOptTransactionHeaderId as intLFutOptTransactionHeaderId
			, ot1.intFutOptTransactionHeaderId as intSFutOptTransactionHeaderId
			, ot.dtmTransactionDate dtmLTransDate
			, ot1.dtmTransactionDate dtmSTransDate
			, ot.dtmFilledDate dtmLFilledDate
			, ot1.dtmFilledDate dtmSFilledDate
			, isnull(ot.dblPrice,0) dblLPrice
			, isnull(ot1.dblPrice,0) dblSPrice
			, ot.strInternalTradeNo strLInternalTradeNo
			, ot1.strInternalTradeNo strSInternalTradeNo
			, ot.strBrokerTradeNo strLBrokerTradeNo
			, ot1.strBrokerTradeNo strSBrokerTradeNo
			, fm.dblContractSize dblContractSize
			, psd.dblFutCommission
			, c.intCurrencyID as intCurrencyId
			, c.strCurrency
			, intMainCurrencyId = CASE WHEN c.ysnSubCurrency = 1 THEN c.intMainCurrencyId ELSE c.intCurrencyID END
			, strMainCurrency = CASE WHEN c.ysnSubCurrency = 0 THEN c.strCurrency ELSE MainCurrency.strCurrency END
			, c.intCent
			, c.ysnSubCurrency
			,psd.intConcurrencyId
		FROM tblRKMatchFuturesPSHeader psh
		JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId
		JOIN tblRKFutOptTransaction ot on psd.intLFutOptTransactionId= ot.intFutOptTransactionId
		LEFT JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId
		LEFT JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
		LEFT JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = c.intMainCurrencyId
		LEFT JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId and ot.intInstrumentTypeId in(1)
		JOIN tblRKFutOptTransaction ot1 on psd.intSFutOptTransactionId= ot1.intFutOptTransactionId
	)t
)t1