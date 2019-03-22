CREATE VIEW [dbo].[vyuPATCalculateCustomerPatronage]
	AS
SELECT	RR.intRefundTypeId,
		intCustomerId = CV.intCustomerPatronId,
		intFiscalYearId = CV.intFiscalYear,
		RRD.intPatronageCategoryId,
		PC.strDescription,
		PC.strCategoryCode,
		RRD.dblRate,
		dblVolume = (CV.dblVolume - CV.dblVolumeProcessed),
		dblRefundAmount = ROUND((RRD.dblRate * (CV.dblVolume - CV.dblVolumeProcessed)),2)
FROM tblPATRefundRate RR
INNER JOIN tblPATRefundRateDetail RRD
	ON RRD.intRefundTypeId = RR.intRefundTypeId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
INNER JOIN tblPATCustomerVolume CV
	ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId AND CV.dblVolume > CV.dblVolumeProcessed