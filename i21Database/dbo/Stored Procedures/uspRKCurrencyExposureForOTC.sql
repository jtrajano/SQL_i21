CREATE PROCEDURE [dbo].[uspRKCurrencyExposureForOTC]
	 @intCurrencyId INT
AS

BEGIN
	DECLARE @intCurrencyCommodityId INT = 0
		
	SELECT @intCurrencyCommodityId = intCommodityId
	FROM tblICCommodity
	WHERE strCommodityCode = 'Currency'

	SELECT intRowNum = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strInternalTradeNo))
		, strInternalTradeNo
		, dtmFilledDate = t.dtmTransactionDate
		, strBuySell
		, b.intBankId
		, strBankName
		, dtmMaturityDate
		, rt.intCurrencyExchangeRateTypeId
		, rt.strCurrencyExchangeRateType
		, dblContractAmount = CASE WHEN strBuySell = 'Buy' THEN dblContractAmount ELSE - dblContractAmount END
		, dblExchangeRate
		, strExchangeFromCurrency = strFromCurrency
		, dblMatchAmount = CASE WHEN strBuySell = 'Buy' THEN - dblMatchAmount ELSE dblMatchAmount END
		, strMatchedFromCurrency = strToCurrency
		, mc.strCompanyName
		, intConcurrencyId = 1
		, intFutOptTransactionId
		, intExchangeRateCurrencyId = c.intCurrencyID
		, intAmountCurrencyId = c.intCurrencyID
		, intCompanyId = mc.intMultiCompanyId
	FROM tblRKFutOptTransaction ft
	JOIN tblRKFutOptTransactionHeader t ON ft.intFutOptTransactionHeaderId = t.intFutOptTransactionHeaderId
	JOIN tblCMBank b ON b.intBankId = ft.intBankId AND ft.intSelectedInstrumentTypeId = 2
	JOIN tblSMCurrencyExchangeRateType rt ON rt.intCurrencyExchangeRateTypeId = ft.intCurrencyExchangeRateTypeId
	JOIN tblSMCurrency c ON c.strCurrency = ft.strFromCurrency
	LEFT JOIN tblSMMultiCompany mc ON mc.intMultiCompanyId = t.intCompanyId
	WHERE ft.intCommodityId = @intCurrencyCommodityId AND ISNULL(ft.ysnLiquidation, 0) = 0
	AND ft.intFromCurrencyId = @intCurrencyId
END