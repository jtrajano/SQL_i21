CREATE VIEW [dbo].[vyuPATVolumeDetails]
		 AS 
	 SELECT CV.intCategoryVolumeId,
			CV.intCustomerPatronId,
			ENT.strName,
			CV.intPatronageCategoryId,
			PC.strCategoryCode,
			PC.strPurchaseSale,
			CV.intFiscalYear,
			FY.strFiscalYear,
			AR.strStockStatus,
			TC.strTaxCode,
			dblPurchase = CASE WHEN PC.strPurchaseSale = 'Purchase' THEN CV.dblVolume ELSE 0 END,
			dblSale = CASE WHEN PC.strPurchaseSale = 'Sale' THEN CV.dblVolume ELSE 0 END,
			CV.dtmLastActivityDate,
			CV.dblVolume,
			CV.intConcurrencyId 
	   FROM tblPATCustomerVolume CV
 INNER JOIN tblEntity ENT
		 ON ENT.intEntityId = intCustomerPatronId
 INNER JOIN tblPATPatronageCategory PC
		 ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
 INNER JOIN tblGLFiscalYear FY
		 ON FY.intFiscalYearId = CV.intFiscalYear
 INNER JOIN tblARCustomer AR
		 ON AR.intEntityCustomerId = CV.intCustomerPatronId
  LEFT JOIN tblSMTaxCode TC
		 ON TC.intTaxCodeId = AR.intTaxCodeId

GO