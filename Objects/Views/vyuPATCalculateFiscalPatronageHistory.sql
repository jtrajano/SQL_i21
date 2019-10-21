CREATE VIEW [dbo].[vyuPATCalculateFiscalPatronageHistory]
	AS
SELECT	NEWID() as id,
		R.intFiscalYearId,
		R.intRefundId,
		PC.strCategoryCode,
		PC.strDescription,
		dblVolume = SUM(RCat.dblVolume),
		RCat.dblRefundRate as dblRate,
		dblRefundAmount = SUM(ROUND(RCat.dblRefundRate * RCat.dblVolume,2))
	FROM tblPATRefundCategory RCat
	INNER JOIN tblPATRefundCustomer RCus
		ON RCus.intRefundCustomerId = RCat.intRefundCustomerId
	INNER JOIN tblPATRefund R
		ON R.intRefundId = RCus.intRefundId
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = RCat.intPatronageCategoryId
	GROUP BY R.intFiscalYearId, R.intRefundId, PC.strCategoryCode, PC.strDescription, RCat.dblRefundRate