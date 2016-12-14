CREATE VIEW [dbo].[vyuPATCustomerVolumeDetail]
	AS
SELECT  CV.intCustomerVolumeId,
		CV.intPatronageCategoryId,
		CV.intCustomerPatronId,
		EM.strName,
		intFiscalYearId = CV.intFiscalYear,
		FY.strFiscalYear,
		PC.strCategoryCode,
		PC.strDescription,
		PC.strPurchaseSale,
		PC.strUnitAmount,
		CV.dblVolume,
		CV.ysnRefundProcessed,
		CV.intConcurrencyId
	FROM tblPATCustomerVolume CV
	INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
	INNER JOIN tblEMEntity EM
		ON EM.intEntityId = CV.intCustomerPatronId
	INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CV.intFiscalYear