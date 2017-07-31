﻿CREATE VIEW [dbo].[vyuPATCalculateRefundPatronage]
	AS
SELECT DISTINCT RRD.intPatronageCategoryId,
		NEWID() AS id,
		RR.intRefundTypeId,
		intFiscalYearId = CV.intFiscalYear,
		PC.strDescription,
		PC.strCategoryCode,
		RRD.dblRate,
		dblVolume = SUM(CV.dblVolume),
		dblRefundAmount = SUM(ROUND(ISNULL((RRD.dblRate * CV.dblVolume),0),2))
	FROM tblPATRefundRate RR
INNER JOIN tblPATRefundRateDetail RRD
	ON RRD.intRefundTypeId = RR.intRefundTypeId
INNER JOIN tblPATPatronageCategory PC
	ON PC.intPatronageCategoryId = RRD.intPatronageCategoryId
INNER JOIN tblPATCustomerVolume CV
	ON CV.intPatronageCategoryId = RRD.intPatronageCategoryId AND CV.ysnRefundProcessed <> 1
INNER JOIN vyuEMEntityType EMType
	ON EMType.intEntityId = CV.intCustomerPatronId AND EMType.Customer = 1 AND EMType.Vendor = 1
GROUP BY RRD.intPatronageCategoryId, RR.intRefundTypeId, CV.intFiscalYear, PC.strCategoryCode, PC.strDescription, RRD.dblRate