CREATE VIEW [dbo].[vyuCMCashFlowReport]
AS
SELECT
	R.intCashFlowReportId,
	R.dtmDateGenerated,
	R.dtmReportDate,
	R.strDescription,
	R.intFilterCurrencyId,
	FC.strCurrency strFilterCurrency,
	R.intReportingCurrencyId,
	RC.strCurrency strReportingCurrency,
	R.intBankId,
	B.strBankName,
	R.intBankAccountId,
	BA.strBankAccountNo strBankAccount,
	R.intCompanyLocationId,
	CL.strLocationName strCompanyLocation,
	R.intEntityId,
	E.strName strEntityName,
	ysnGenerated = CAST((CASE WHEN ISNULL(ReportSummary.intCount, 0) > 0 THEN 1 ELSE 0 END) AS BIT),
	R.intBucket1RateTypeId,
	Bucket1RateType.strCurrencyExchangeRateType strBucket1RateType,
	R.intBucket2RateTypeId,
	Bucket2RateType.strCurrencyExchangeRateType strBucket2RateType,
	R.intBucket3RateTypeId,
	Bucket3RateType.strCurrencyExchangeRateType strBucket3RateType,
	R.intBucket4RateTypeId,
	Bucket4RateType.strCurrencyExchangeRateType strBucket4RateType,
	R.intBucket5RateTypeId,
	Bucket5RateType.strCurrencyExchangeRateType strBucket5RateType,
	R.intBucket6RateTypeId,
	Bucket6RateType.strCurrencyExchangeRateType strBucket6RateType,
	R.intBucket7RateTypeId,
	Bucket7RateType.strCurrencyExchangeRateType strBucket7RateType,
	R.intBucket8RateTypeId,
	Bucket8RateType.strCurrencyExchangeRateType strBucket8RateType,
	R.intBucket9RateTypeId,
	Bucket9RateType.strCurrencyExchangeRateType strBucket9RateType,
	R.intConcurrencyId
FROM tblCMCashFlowReport R
LEFT JOIN tblCMBank B 
	ON B.intBankId = R.intBankId
LEFT JOIN vyuCMBankAccount BA
	ON BA.intBankAccountId = R.intBankAccountId
LEFT JOIN tblSMCurrency FC 
	ON FC.intCurrencyID = R.intFilterCurrencyId
LEFT JOIN tblSMCurrency RC
	ON RC.intCurrencyID = R.intReportingCurrencyId
LEFT JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = R.intCompanyLocationId
LEFT JOIN tblEMEntity E
	ON E.intEntityId = R.intEntityId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket1RateType
	ON Bucket1RateType.intCurrencyExchangeRateTypeId = R.intBucket1RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket2RateType
	ON Bucket2RateType.intCurrencyExchangeRateTypeId = R.intBucket2RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket3RateType
	ON Bucket3RateType.intCurrencyExchangeRateTypeId = R.intBucket3RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket4RateType
	ON Bucket4RateType.intCurrencyExchangeRateTypeId = R.intBucket4RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket5RateType
	ON Bucket5RateType.intCurrencyExchangeRateTypeId = R.intBucket5RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket6RateType
	ON Bucket6RateType.intCurrencyExchangeRateTypeId = R.intBucket6RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket7RateType
	ON Bucket7RateType.intCurrencyExchangeRateTypeId = R.intBucket7RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket8RateType
	ON Bucket8RateType.intCurrencyExchangeRateTypeId = R.intBucket8RateTypeId
LEFT JOIN tblSMCurrencyExchangeRateType Bucket9RateType
	ON Bucket9RateType.intCurrencyExchangeRateTypeId = R.intBucket9RateTypeId
OUTER APPLY
(
	SELECT COUNT(1) intCount FROM tblCMCashFlowReportSummary
	WHERE intCashFlowReportId = R.intCashFlowReportId
) ReportSummary

