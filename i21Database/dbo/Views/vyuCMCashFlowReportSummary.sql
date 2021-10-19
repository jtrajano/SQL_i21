CREATE VIEW [dbo].[vyuCMCashFlowReportSummary]
AS 
SELECT
	S.intCashFlowReportId,
	S.intCashFlowReportSummaryId,
	G.intCashFlowReportSummaryGroupId,
	G.strCashFlowReportSummaryGroup,
	C.intCashFlowReportSummaryCodeId,
	C.strCashFlowReportSummaryCode,
	BA.intBankAccountId,
	BA.strBankAccountNo strBankAccountId,
	RC.intCurrencyID intReportingCurrencyId,
	RC.strCurrency strReportingCurrency,
	CL.intCompanyLocationId,
	CL.strLocationName strCompanyLocation,
	G.intGroupSort,
	C.intReportSort,
	C.strOperation,
	C.strReport,
	C.strReportDescription,
	S.dtmReportDate,
	S.dblBucket1,
	S.dblBucket2,
	S.dblBucket3,
	S.dblBucket4,
	S.dblBucket5,
	S.dblBucket6,
	S.dblBucket7,
	S.dblBucket8,
	S.dblBucket9,
	S.dblTotal,
	S.intConcurrencyId
FROM tblCMCashFlowReportSummary S
LEFT JOIN tblCMCashFlowReportSummaryCode C
	ON C.intCashFlowReportSummaryCodeId = S.intCashFlowReportSummaryCodeId
LEFT JOIN tblCMCashFlowReportSummaryGroup G
	ON G.intCashFlowReportSummaryGroupId = C.intCashFlowReportSummaryGroupId
LEFT JOIN tblCMBankAccount BA
	ON BA.intBankAccountId = S.intBankAccountId
LEFT JOIN tblSMCurrency RC
	ON RC.intCurrencyID = S.intReportingCurrencyId
LEFT JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = S.intCompanyLocationId

