CREATE PROCEDURE uspPATGetEquityPatronageDetails 
	@intCustomerId INT = NULL
AS
BEGIN
	SELECT	RRD.intRefundTypeId,
			PC.strCategoryCode,
			PC.strPurchaseSale,
			PC.strUnitAmount,
			CE.dblEquity,
			RRD.intConcurrencyId
	FROM tblPATCustomerVolume CV
	INNER JOIN tblPATPatronageCategory PC
		ON CV.intPatronageCategoryId = PC.intPatronageCategoryId
	INNER JOIN tblPATRefundRateDetail RRD
		ON RRD.intPatronageCategoryId = PC.intPatronageCategoryId
	INNER JOIN tblPATCustomerEquity CE
		ON CE.intRefundTypeId = RRD.intRefundTypeId AND CE.intCustomerId = CV.intCustomerPatronId
	WHERE CV.intCustomerPatronId = @intCustomerId
END
GO