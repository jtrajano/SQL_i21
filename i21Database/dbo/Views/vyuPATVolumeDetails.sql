CREATE VIEW [dbo].[vyuPATVolumeDetails]
		 AS 
	 SELECT	CV.intCustomerPatronId,
			ENT.strName,
			CV.intFiscalYear,
			FY.strFiscalYear,
			AR.strStockStatus,
			TC.strTaxCode,
			dblPurchase = sum(CASE WHEN PC.strPurchaseSale = 'Purchase' THEN CV.dblVolume ELSE 0 END),
			dblSale = sum(CASE WHEN PC.strPurchaseSale = 'Sale' THEN CV.dblVolume ELSE 0 END),
			dtmLastActivityDate = max(CV.dtmLastActivityDate),
			dblVolume = sum(CV.dblVolume),
			CV.intConcurrencyId 
	   FROM tblPATCustomerVolume CV
 INNER JOIN tblEMEntity ENT
		 ON ENT.intEntityId = intCustomerPatronId
 INNER JOIN tblPATPatronageCategory PC
		 ON PC.intPatronageCategoryId = CV.intPatronageCategoryId
 INNER JOIN tblGLFiscalYear FY
		 ON FY.intFiscalYearId = CV.intFiscalYear
 INNER JOIN tblARCustomer AR
		 ON AR.intEntityCustomerId = CV.intCustomerPatronId
  LEFT JOIN tblSMTaxCode TC
		 ON TC.intTaxCodeId = AR.intTaxCodeId
		 group by CV.intCustomerPatronId,
		 ENT.strName, CV.intFiscalYear,FY.strFiscalYear,
		 AR.strStockStatus,TC.strTaxCode,CV.intConcurrencyId

GO