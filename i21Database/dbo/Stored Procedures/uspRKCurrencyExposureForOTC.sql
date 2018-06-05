CREATE PROC uspRKCurrencyExposureForOTC
		 @intWeightUOMId int = null
		,@intCompanyId int = null
		,@intCommodityId int 
		,@dtmMarketPremium datetime =null
		,@dtmClosingPrice datetime=null
		,@intCurrencyId int
AS

SELECT 
convert(int,ROW_NUMBER() OVER(order by strInternalTradeNo)) as intRowNum,
strInternalTradeNo,dtmFilledDate,strBuySell,b.intBankId,strBankName,dtmMaturityDate,rt.intCurrencyExchangeRateTypeId,rt.strCurrencyExchangeRateType 
	,case when strBuySell='Buy' then dblContractAmount else -dblContractAmount end dblContractAmount,
	dblExchangeRate,strFromCurrency strExchangeFromCurrency,dblMatchAmount,strFromCurrency strMatchedFromCurrency,mc.strCompanyName,1 as intConcurrencyId
FROM tblRKFutOptTransaction ft
JOIN tblRKFutOptTransactionHeader  t on ft.intFutOptTransactionHeaderId=t.intFutOptTransactionHeaderId
JOIN tblCMBank b on b.intBankId=ft.intBankId AND ft.intSelectedInstrumentTypeId=2
JOIN tblSMCurrencyExchangeRateType rt on rt.intCurrencyExchangeRateTypeId=ft.intCurrencyExchangeRateTypeId
LEFT JOIN tblSMMultiCompany mc on mc.intMultiCompanyId=t.intCompanyId
WHERE ft.intCurrencyId=@intCurrencyId and ft.intCommodityId=@intCommodityId and isnull(ft.ysnLiquidation,0) =0