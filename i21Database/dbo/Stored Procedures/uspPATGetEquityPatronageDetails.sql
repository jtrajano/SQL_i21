CREATE PROCEDURE uspPATGetEquityPatronageDetails 
	@intCustomerId INT = NULL
AS
BEGIN
	SELECT RR.intRefundTypeId, 
		   PC.strCategoryCode,
		   PC.strPurchaseSale,
		   PC.strUnitAmount,
		   CE.dblEquity,
		   RR.intConcurrencyId
	  FROM tblPATRefundRate RR
INNER JOIN tblPATRefundRateDetail RRD
		ON RRD.intRefundTypeId = RR.intRefundTypeId
INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
INNER JOIN tblPATCustomerEquity CE
		ON CE.intRefundTypeId = RR.intRefundTypeId
	 WHERE CE.intCustomerId = @intCustomerId
END
GO