CREATE VIEW vyuRKGetCurrencyPair

AS  

SELECT intCurrencyExchangeRateTypeId 
	, strCurrencyExchangeRateType
	, fxRate.intFromCurrencyId
	, fxRate.intToCurrencyId
	, strFromCurrency = fromCurr.strCurrency
	, strToCurrency = toCurr.strCurrency
FROM tblSMCurrencyExchangeRateType fxType
OUTER APPLY (
	SELECT TOP 1 intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRateDetail fxD
	WHERE fxD.intRateTypeId = fxType.intCurrencyExchangeRateTypeId
	AND dtmValidFromDate <= GETDATE()
	ORDER BY dtmValidFromDate DESC
) fxDetail
LEFT JOIN tblSMCurrencyExchangeRate fxRate
	ON fxRate.intCurrencyExchangeRateId = fxDetail.intCurrencyExchangeRateId
LEFT JOIN tblSMCurrency fromCurr
	ON fromCurr.intCurrencyID = fxRate.intFromCurrencyId
LEFT JOIN tblSMCurrency toCurr
	ON toCurr.intCurrencyID = fxRate.intToCurrencyId
WHERE fxRate.intFromCurrencyId IS NOT NULL
AND fxRate.intToCurrencyId IS NOT NULL