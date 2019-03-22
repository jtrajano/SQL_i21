CREATE VIEW [dbo].[vyuPATEquityPayDetail]
	AS
SELECT	EPD.intEquityPayDetailId,
		EPD.intEquityPaySummaryId,
		EPD.intFiscalYearId,
		FY.strFiscalYear,
		EPD.strEquityType,
		EPD.intRefundTypeId,
		RR.strRefundType,
		EPD.ysnQualified,
		EPD.dblEquityAvailable,
		EPD.dblEquityPay,
		EPD.intConcurrencyId
FROM tblPATEquityPayDetail EPD
INNER JOIN tblPATRefundRate RR
	ON RR.intRefundTypeId = EPD.intRefundTypeId
INNER JOIN tblGLFiscalYear FY
	ON FY.intFiscalYearId = EPD.intFiscalYearId