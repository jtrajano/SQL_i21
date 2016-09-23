CREATE VIEW [dbo].[vyuPATCalculateRefundPatronage]
	AS
SELECT DISTINCT RRD.intPatronageCategoryId,
		NEWID() AS id,
		RR.intRefundTypeId,
		intFiscalYearId = CV.intFiscalYear,
		PC.strDescription,
		PC.strCategoryCode,
		RRD.dblRate,
		dblVolume = SUM(CV.dblVolume),
		dblRefundAmount = SUM(ISNULL((RRD.dblRate * CV.dblVolume),0))
	FROM tblPATRefundRate RR
INNER JOIN tblPATRefundRateDetail RRD
	ON RRD.intRefundTypeId = RR.intRefundTypeId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
INNER JOIN tblPATCustomerVolume CV
	ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId
GROUP BY RRD.intPatronageCategoryId, RR.intRefundTypeId, CV.intFiscalYear, PC.strCategoryCode, PC.strDescription, RRD.dblRate