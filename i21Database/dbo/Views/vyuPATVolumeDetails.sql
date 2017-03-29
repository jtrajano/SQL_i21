CREATE VIEW [dbo].[vyuPATVolumeDetails]
	AS 
SELECT	id = NEWID(),
		CV.intCustomerPatronId,
		ENT.strName,
		CV.intFiscalYear,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		dblPurchase = SUM(CASE WHEN PC.strPurchaseSale = 'Purchase' THEN CV.dblVolume ELSE 0 END),
		dblSale = SUM(CASE WHEN PC.strPurchaseSale = 'Sale' THEN CV.dblVolume ELSE 0 END),
		dtmLastActivityDate = MAX(AR.dtmLastActivityDate),
		dblTotalVolume = SUM(CV.dblVolume),
		CV.ysnRefundProcessed
	FROM tblPATCustomerVolume CV
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = intCustomerPatronId
INNER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CV.intFiscalYear
INNER JOIN tblARCustomer AR
		ON AR.[intEntityId] = CV.intCustomerPatronId
LEFT JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = AR.intTaxCodeId
		GROUP BY	CV.intCustomerPatronId,
					ENT.strName, 
					CV.intFiscalYear, 
					FY.strFiscalYear,
					AR.strStockStatus, 
					TC.strTaxCode, 
					CV.ysnRefundProcessed