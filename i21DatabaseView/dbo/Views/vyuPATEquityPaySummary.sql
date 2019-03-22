CREATE VIEW [dbo].[vyuPATEquityPaySummary]
	AS
SELECT	EPS.intEquityPaySummaryId,
		EP.intEquityPayId,
		EPS.intCustomerPatronId,
		ENT.strName,
		EPS.ysnQualified,
		EPS.dblEquityAvailable,
		EPS.dblEquityPaid,
		EPS.dblFWT,
		EPS.dblCheckAmount,
		EPS.intBillId,
		APB.strBillId,
		EPS.intConcurrencyId
FROM tblPATEquityPaySummary EPS
INNER JOIN tblPATEquityPay EP
	ON EP.intEquityPayId = EPS.intEquityPayId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = EPS.intCustomerPatronId
LEFT JOIN tblAPBill APB
	ON APB.intBillId = EPS.intBillId