CREATE VIEW [dbo].[vyuPATCalculateRefundPatronageHistory]
	AS
SELECT	NEWID() as id,
		RCus.intRefundId,
		RCus.intRefundTypeId,
		PC.strCategoryCode,
		PC.strDescription,
		RCat.dblVolume,
		RCat.dblRefundRate AS dblRate,
		dblRefundAmount = ROUND(RCat.dblVolume * RCat.dblRefundRate,2)
		FROM tblPATRefundCategory RCat
	INNER JOIN tblPATRefundCustomer RCus
		ON RCus.intRefundCustomerId = RCat.intRefundCustomerId
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RCus.intRefundId