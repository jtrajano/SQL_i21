CREATE PROC uspRKCurrencyExposureForOTC
	 @intCommodityId int
AS

BEGIN
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strInternalTradeNo)) as intRowNum
		, strInternalTradeNo
		,t.dtmTransactionDate dtmFilledDate
		, strBuySell
		, b.intBankId
		, strBankName
		, dtmMaturityDate
		, rt.intCurrencyExchangeRateTypeId
		, rt.strCurrencyExchangeRateType
		, case when strBuySell = 'Buy' then dblContractAmount else -dblContractAmount end dblContractAmount
		, dblExchangeRate
		, strFromCurrency strExchangeFromCurrency
		, dblMatchAmount
		, strFromCurrency strMatchedFromCurrency	
		, mc.strCompanyName
		, 1 as intConcurrencyId,intFutOptTransactionId, c.intCurrencyID intExchangeRateCurrencyId, c.intCurrencyID intAmountCurrencyId,mc.intMultiCompanyId intCompanyId
	FROM tblRKFutOptTransaction ft
	JOIN tblRKFutOptTransactionHeader  t on ft.intFutOptTransactionHeaderId=t.intFutOptTransactionHeaderId
	JOIN tblCMBank b on b.intBankId=ft.intBankId AND ft.intSelectedInstrumentTypeId=2
	JOIN tblSMCurrencyExchangeRateType rt on rt.intCurrencyExchangeRateTypeId=ft.intCurrencyExchangeRateTypeId
	JOIN tblSMCurrency c on c.strCurrency =ft.strFromCurrency
	LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=t.intCompanyId
	WHERE ft.intCommodityId=@intCommodityId and isnull(ft.ysnLiquidation,0) =0 
END
