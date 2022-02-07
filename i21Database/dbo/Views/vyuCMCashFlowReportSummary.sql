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
	dbo.fnAESDecryptASym(BA.strBankAccountNo) strBankAccountId,
	B.strBankName,
	BA.intCurrencyId intBankAccountCurrencyId,
	Currency.strCurrency strBankAccountCurrency,
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
	ysnHasZeroAmountTransaction = CAST((CASE WHEN ISNULL(SummaryDetail.intCount, 0) > 0 THEN 1 ELSE 0 END)AS BIT),
	S.intConcurrencyId
FROM tblCMCashFlowReportSummary S
LEFT JOIN tblCMCashFlowReportSummaryCode C
	ON C.intCashFlowReportSummaryCodeId = S.intCashFlowReportSummaryCodeId
LEFT JOIN tblCMCashFlowReportSummaryGroup G
	ON G.intCashFlowReportSummaryGroupId = C.intCashFlowReportSummaryGroupId
LEFT JOIN tblCMBankAccount BA
	ON BA.intBankAccountId = S.intBankAccountId
LEFT JOIN tblCMBank B 
	ON B.intBankId = BA.intBankId
LEFT JOIN tblSMCurrency Currency
	ON Currency.intCurrencyID = BA.intCurrencyId
LEFT JOIN tblSMCurrency RC
	ON RC.intCurrencyID = S.intReportingCurrencyId
LEFT JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = S.intCompanyLocationId
OUTER APPLY (
	SELECT COUNT(1) intCount FROM tblCMCashFlowReportSummaryDetail SD
	WHERE SD.intCashFlowReportSummaryId = S.intCashFlowReportSummaryId
		AND SD.dblBucket1 = 0
		AND SD.dblBucket2 = 0
		AND SD.dblBucket3 = 0
		AND SD.dblBucket4 = 0
		AND SD.dblBucket5 = 0
		AND SD.dblBucket6 = 0
		AND SD.dblBucket7 = 0
		AND SD.dblBucket8 = 0
		AND SD.dblBucket9 = 0
) SummaryDetail
