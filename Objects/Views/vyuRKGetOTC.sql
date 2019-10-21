CREATE VIEW vyuRKGetOTC
AS
SELECT cc.intCurExpCurrencyContractId
		,cc.intConcurrencyId
		,cc.intCurrencyExposureId
		,cc.intFutOptTransactionId
		,cc.dtmDate dtmFilledDate
		,cc.strBuySell
		,cc.intBankId
		,cc.dtmMaturityDate
		,cc.strCurrencyPair strCurrencyExchangeRateType
		,cc.dblAmount dblContractAmount
		,cc.intAmountCurrencyId
		,cc.dblExchangeRate
		,cc.intExchangeRateCurrencyId
		,cc.dblBalanceAmount dblMatchAmount
		,cc.intBalanceAmountCurrencyId
		,cc.intCompanyId 
		,strBankName
		,c.strCurrency strMatchedFromCurrency
		,c.strCurrency strExchangeFromCurrency
		,strInternalTradeNo		

FROM tblRKCurExpCurrencyContract cc
join tblRKFutOptTransaction ft on ft.intFutOptTransactionId=cc.intFutOptTransactionId
join tblCMBank b on b.intBankId=cc.intBankId
join tblSMCurrency c on c.intCurrencyID=cc.intAmountCurrencyId
join tblSMCurrency c1 on c1.intCurrencyID=cc.intExchangeRateCurrencyId