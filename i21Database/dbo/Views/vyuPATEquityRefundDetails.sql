CREATE VIEW [dbo].[vyuPATEquityRefundDetails]
	AS
SELECT	newid() as id,
		RR.intRefundTypeId,
		CE.strEquityType,
		CE.intCustomerId,
		RR.strRefundType,
		CE.dblEquity,
		RR.intConcurrencyId,
		RR.ysnQualified 
	FROM tblPATRefundRate RR
	INNER JOIN tblPATRefundRateDetail RRD
		ON RRD.intRefundTypeId = RR.intRefundTypeId
	INNER JOIN tblPATCustomerEquity CE
		ON CE.intRefundTypeId = RR.intRefundTypeId