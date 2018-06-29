CREATE VIEW [dbo].[vyuPATCalculateFiscalPatronage]
	AS
SELECT	DISTINCT RRD.intPatronageCategoryId,
		NEWID() as id,
		intFiscalYearId = CV.intFiscalYear,
		PC.strDescription,
		PC.strCategoryCode,
		RRD.dblRate,
		dblVolume = SUM(ROUND(CV.dblVolume, 2)),
		dblRefundAmount = SUM(ROUND(ISNULL((RRD.dblRate * CV.dblVolume),0),2))
		FROM tblPATRefundRate RR
INNER JOIN tblPATRefundRateDetail RRD
	ON RRD.intRefundTypeId = RR.intRefundTypeId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
INNER JOIN tblPATCustomerVolume CV
	ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId AND CV.ysnRefundProcessed <> 1
GROUP BY RRD.intPatronageCategoryId, CV.intFiscalYear, PC.strCategoryCode, PC.strDescription, RRD.dblRate