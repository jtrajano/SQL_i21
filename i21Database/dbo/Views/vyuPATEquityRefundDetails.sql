CREATE VIEW [dbo].[vyuPATEquityRefundDetails]
	AS
SELECT	NEWID() as id,
		CE.intFiscalYearId,
		RR.intRefundTypeId,
		CE.strEquityType,
		CE.intCustomerId,
		RR.strRefundType,
		CE.dblEquity,
		RR.intConcurrencyId,
		RR.ysnQualified 
	FROM tblPATCustomerEquity CE
	INNER JOIN tblPATRefundRate RR
		ON CE.intRefundTypeId = RR.intRefundTypeId