CREATE VIEW [dbo].[vyuPATCustomerVolumeDetail]
	AS
SELECT  intCustomerVolumeId = CV.intCustomerVolumeId,
		intPatronageCategoryId = CV.intPatronageCategoryId,
		intCustomerPatronId = CV.intCustomerPatronId,
		intFiscalYearId = CV.intFiscalYear,
		strFiscalYear = FY.strFiscalYear,
		strCategoryCode = PC.strCategoryCode,
		strDescription = PC.strDescription,
		strPurchaseSale = PC.strPurchaseSale,
		strUnitAmount = PC.strUnitAmount,
		dblVolume = CV.dblVolume,
		ysnRefundProcessed = CV.ysnRefundProcessed,
		intConcurrencyId = CV.intConcurrencyId
	FROM tblPATCustomerVolume CV
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
	INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CV.intFiscalYear