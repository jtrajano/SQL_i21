CREATE VIEW [dbo].[vyuPATGetCustomerEquityRefundDetails]
	AS
SELECT RR.intRefundTypeId,
				CE.strEquityType, 
				RR.strRefundType,
				CE.dblEquity,
			    RR.intConcurrencyId,
				RR.ysnQualified
		   FROM tblPATRefundRate RR
	 INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intRefundTypeId = RR.intRefundTypeId
	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
	 INNER JOIN tblPATCustomerEquity CE
			 ON CE.intRefundTypeId = RR.intRefundTypeId
	   GROUP BY RR.intRefundTypeId, CE.strEquityType, RR.strRefundType, RR.intConcurrencyId, CE.dblEquity, RR.ysnQualified
GO