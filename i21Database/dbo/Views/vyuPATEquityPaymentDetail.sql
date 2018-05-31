CREATE VIEW [dbo].[vyuPATEquityPaymentDetail]
	AS
SELECT	CAST(ROW_NUMBER() OVER (ORDER BY EP.intEquityPayId) AS INT) as id,
		EP.intEquityPayId,
		EP.strPaymentNumber,
		EP.strPayoutType,
		EP.dblPayoutPercent,
		EP.dtmPaymentDate,
		EP.strDistributionMethod,
		EPS.intCustomerPatronId,
		EM.strName,
		EPD.intFiscalYearId,
		FY.strFiscalYear,
		EPD.strEquityType,
		EPD.intRefundTypeId,
		RR.strRefundType,
		EPD.dblEquityAvailable,
		EPD.dblEquityPay,
		EPS.intBillId,
		APB.strBillId
FROM tblPATEquityPay EP
INNER JOIN tblPATEquityPaySummary EPS
	ON EPS.intEquityPayId = EP.intEquityPayId
INNER JOIN tblPATEquityPayDetail EPD
	ON EPD.intEquityPaySummaryId = EPS.intEquityPaySummaryId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = EPS.intCustomerPatronId
INNER JOIN tblGLFiscalYear FY
	ON FY.intFiscalYearId = EPD.intFiscalYearId
INNER JOIN tblPATRefundRate RR
	ON RR.intRefundTypeId = EPD.intRefundTypeId
LEFT JOIN tblAPBill APB
	ON APB.intBillId = EPS.intBillId