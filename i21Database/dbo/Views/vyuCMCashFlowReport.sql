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
OUTER APPLY
(
	SELECT COUNT(1) intCount FROM tblCMCashFlowReportSummary
	WHERE intCashFlowReportId = R.intCashFlowReportId
) ReportSummary

