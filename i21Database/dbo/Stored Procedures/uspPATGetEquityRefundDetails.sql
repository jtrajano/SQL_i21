CREATE PROCEDURE [dbo].[uspPATGetEquityRefundDetails]
	@intRefundTypeId INT = NULL
AS
BEGIN

SELECT DISTINCT RR.intRefundTypeId,
				CE.strEquityType, 
				RR.strRefundType,
				dblEquity = SUM(CE.dblEquity),
			    RR.intConcurrencyId
		   FROM tblPATRefundRate RR
	 INNER JOIN tblPATRefundRateDetail RRD
			 ON RRD.intRefundTypeId = RR.intRefundTypeId
	 INNER JOIN tblPATPatronageCategory PC
			 ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
	 INNER JOIN tblPATCustomerEquity CE
			 ON CE.intRefundTypeId = RR.intRefundTypeId
		  WHERE RR.intRefundTypeId = @intRefundTypeId
	   GROUP BY RR.intRefundTypeId, CE.strEquityType, RR.strRefundType, RR.intConcurrencyId


END

GO
