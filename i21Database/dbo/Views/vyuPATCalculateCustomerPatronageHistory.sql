CREATE VIEW [dbo].[vyuPATCalculateCustomerPatronageHistory]
	AS
SELECT	DISTINCT RCat.intPatronageCategoryId,
		R.intRefundId,
		RCus.intCustomerId,
		PC.strDescription,
		PC.strCategoryCode,
		dblRate = RCat.dblRefundRate,
		RCat.dblVolume,
		RCus.dblRefundAmount
FROM tblPATRefundCustomer RCus
INNER JOIN tblPATRefund R
	ON RCus.intRefundId = R.intRefundId
INNER JOIN tblPATRefundCategory RCat
	ON RCat.intRefundCustomerId = RCus.intRefundCustomerId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId