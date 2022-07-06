CREATE VIEW [dbo].[vyuCMCashFlowReportRate]
AS
SELECT
	R.intCashFlowReportRateId,
	R.intCashFlowReportId,
	R.intFilterCurrencyId,
	FC.strCurrency strFilterCurrency,
	R.dblRateBucket1,
	R.dblRateBucket2,
	R.dblRateBucket3,
	R.dblRateBucket4,
	R.dblRateBucket5,
	R.dblRateBucket6,
	R.dblRateBucket7,
	R.dblRateBucket8,
	R.dblRateBucket9,
	R.intConcurrencyId
FROM tblCMCashFlowReportRate R
LEFT JOIN tblSMCurrency FC 
	ON FC.intCurrencyID = R.intFilterCurrencyId