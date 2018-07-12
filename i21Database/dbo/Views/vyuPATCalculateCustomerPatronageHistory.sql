CREATE VIEW [dbo].[vyuPATCalculateCustomerPatronageHistory]
	AS
SELECT	RCat.intRefundCategoryId,
		RCat.intRefundCustomerId,
		RCus.intRefundTypeId,
		RCat.intPatronageCategoryId,
		R.intRefundId,
		RCus.intCustomerId,
		PC.strDescription,
		PC.strCategoryCode,
		dblRate = RCat.dblRefundRate,
		RCat.dblVolume,
		dblRefundAmount =  RCat.dblRefundRate * RCat.dblVolume
FROM tblPATRefundCustomer RCus
INNER JOIN tblPATRefund R
	ON RCus.intRefundId = R.intRefundId
INNER JOIN tblPATRefundCategory RCat
	ON RCat.intRefundCustomerId = RCus.intRefundCustomerId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId