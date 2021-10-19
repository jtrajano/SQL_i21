CREATE VIEW [dbo].[vyuCMCashFlowReportRateType]
AS
SELECT
	RT.intCashFlowReportRateTypeId,
	RT.intCashFlowReportId,
	RT.intFilterCurrencyId,
	FC.strCurrency strFilterCurrency,
	RT.intRateTypeBucket1,
	B1.strCurrencyExchangeRateType strRateTypeBucket1, 
	RT.intRateTypeBucket2,
	B2.strCurrencyExchangeRateType strRateTypeBucket2,
	RT.intRateTypeBucket3,
	B3.strCurrencyExchangeRateType strRateTypeBucket3,
	RT.intRateTypeBucket4,
	B4.strCurrencyExchangeRateType strRateTypeBucket4,
	RT.intRateTypeBucket5,
	B5.strCurrencyExchangeRateType strRateTypeBucket5,
	RT.intRateTypeBucket6,
	B6.strCurrencyExchangeRateType strRateTypeBucket6,
	RT.intRateTypeBucket7,
	B7.strCurrencyExchangeRateType strRateTypeBucket7,
	RT.intRateTypeBucket8,
	B8.strCurrencyExchangeRateType strRateTypeBucket8,
	RT.intRateTypeBucket9,
	B9.strCurrencyExchangeRateType strRateTypeBucket9,
	RT.intConcurrencyId
FROM tblCMCashFlowReportRateType RT
LEFT JOIN tblSMCurrency FC 
	ON FC.intCurrencyID = RT.intFilterCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType B1 
	ON B1.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket1
LEFT JOIN tblSMCurrencyExchangeRateType B2 
	ON B2.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket2
LEFT JOIN tblSMCurrencyExchangeRateType B3 
	ON B3.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket3
LEFT JOIN tblSMCurrencyExchangeRateType B4 
	ON B4.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket4
LEFT JOIN tblSMCurrencyExchangeRateType B5
	ON B5.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket5
LEFT JOIN tblSMCurrencyExchangeRateType B6 
	ON B6.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket6
LEFT JOIN tblSMCurrencyExchangeRateType B7 
	ON B7.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket7
LEFT JOIN tblSMCurrencyExchangeRateType B8 
	ON B8.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket8
LEFT JOIN tblSMCurrencyExchangeRateType B9 
	ON B9.intCurrencyExchangeRateTypeId = RT.intRateTypeBucket9