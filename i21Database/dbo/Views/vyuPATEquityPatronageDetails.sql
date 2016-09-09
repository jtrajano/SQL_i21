CREATE VIEW [dbo].[vyuPATEquityPatronageDetails]
	AS 
SELECT	RRD.intRefundTypeId,
		PC.strCategoryCode,
		PC.strPurchaseSale,
		PC.strUnitAmount,
		CE.dblEquity,
		CV.intCustomerPatronId,
		RRD.intConcurrencyId
FROM tblPATCustomerVolume CV
INNER JOIN tblPATPatronageCategory PC
	ON CV.intPatronageCategoryId = PC.intPatronageCategoryId
INNER JOIN tblPATRefundRateDetail RRD
	ON RRD.intPatronageCategoryId = PC.intPatronageCategoryId
INNER JOIN tblPATCustomerEquity CE
	ON CE.intRefundTypeId = RRD.intRefundTypeId AND CE.intCustomerId = CV.intCustomerPatronId
GO