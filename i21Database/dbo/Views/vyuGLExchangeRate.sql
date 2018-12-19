CREATE VIEW [dbo].[vyuGLExchangeRate] AS
SELECT  
rateType.intCurrencyExchangeRateTypeId,
detail.intCurrencyExchangeRateDetailId,detail.dblRate,
rateType.strCurrencyExchangeRateType COLLATE Latin1_General_CI_AS strCurrencyExchangeRateType,
account.intAccountId, 
account.strAccountId COLLATE Latin1_General_CI_AS strAccountId,
detail.dtmValidFromDate ,rate.intFromCurrencyId , 
rate.intToCurrencyId  FROM tblSMCurrencyExchangeRate rate JOIN
tblSMCurrencyExchangeRateDetail detail ON rate.intCurrencyExchangeRateId = detail.intCurrencyExchangeRateId
JOIN tblSMCurrencyExchangeRateType rateType ON rateType.intCurrencyExchangeRateTypeId = detail.intRateTypeId
LEFT JOIN tblGLAccount account ON account.intCurrencyExchangeRateTypeId = rateType.intCurrencyExchangeRateTypeId