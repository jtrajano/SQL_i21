﻿CREATE VIEW [dbo].[vyuPATCalculateCustomerPatronage]
	AS
SELECT	RR.intRefundTypeId,
		intCustomerId = CV.intCustomerPatronId,
		intFiscalYearId = CV.intFiscalYear,
		RRD.intPatronageCategoryId,
		PC.strDescription,
		PC.strCategoryCode,
		RRD.dblRate,
		dblVolume = CV.dblVolume,
		dblRefundAmount = CASE WHEN ComPref.dblMinimumRefund > ISNULL((RRD.dblRate * CV.dblVolume),0) THEN 0 ELSE (RRD.dblRate * CV.dblVolume) END
FROM tblPATRefundRate RR
INNER JOIN tblPATRefundRateDetail RRD
	ON RRD.intRefundTypeId = RR.intRefundTypeId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
INNER JOIN tblPATCustomerVolume CV
	ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId AND CV.ysnRefundProcessed <> 1 AND CV.dblVolume <> 0
CROSS APPLY tblPATCompanyPreference ComPref