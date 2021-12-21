CREATE VIEW [dbo].[vyuCMCashFlowReportSummaryDetail]
AS 
SELECT 
	Detail.intCashFlowReportSummaryDetailId,
	Detail.intCashFlowReportSummaryId,
	Detail.intCashFlowReportId,
	Detail.intTransactionId,
	Detail.strTransactionId,
	Detail.dtmTransactionDate,
	Detail.strTransactionType,
	Detail.dblBucket1,
	Detail.dblBucket2,
	Detail.dblBucket3,
	Detail.dblBucket4,
	Detail.dblBucket5,
	Detail.dblBucket6,
	Detail.dblBucket7,
	Detail.dblBucket8,
	Detail.dblBucket9,
	Detail.dblRate,
	Detail.intCurrencyId,
	Currency.strCurrency,
	Detail.intReportingCurrencyId,
	ReportingCurrency.strCurrency strReportingCurrency,
	Detail.intCurrencyExchangeRateTypeId,
	RateType.strCurrencyExchangeRateType,
	Detail.intAccountId,
	GLAccount.strAccountId,
	Detail.intBankAccountId,
	dbo.fnAESDecryptASym(BankAccount.strBankAccountNo) + ' - ' + Bank.strBankName  strBankAccountId,
	Detail.intCompanyLocationId,
	CompanyLocation.strLocationName strCompanyLocation,
	Detail.intConcurrencyId
FROM tblCMCashFlowReportSummaryDetail Detail
JOIN tblCMCashFlowReportSummary Summary
	ON Summary.intCashFlowReportSummaryId = Detail.intCashFlowReportSummaryId
LEFT JOIN tblCMBankAccount BankAccount
	ON BankAccount.intBankAccountId = Detail.intBankAccountId
LEFT JOIN tblCMBank Bank
	ON Bank.intBankId = BankAccount.intBankId
LEFT JOIN tblGLAccount GLAccount
	ON GLAccount.intAccountId = Detail.intAccountId
LEFT JOIN tblSMCurrency Currency
	ON Currency.intCurrencyID = Detail.intCurrencyId
LEFT JOIN tblSMCurrency ReportingCurrency
	ON ReportingCurrency.intCurrencyID = Detail.intReportingCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType RateType
	ON RateType.intCurrencyExchangeRateTypeId = Detail.intCurrencyExchangeRateTypeId
LEFT JOIN tblSMCompanyLocation CompanyLocation
	ON CompanyLocation.intCompanyLocationId = Detail.intCompanyLocationId
