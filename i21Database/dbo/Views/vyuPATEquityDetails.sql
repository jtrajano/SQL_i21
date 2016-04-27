﻿CREATE VIEW [dbo].[vyuPATEquityDetails]
	AS 
	 SELECT CE.intCustomerId,
			ENT.strName,
			CE.intFiscalYearId,
			FY.strFiscalYear,
			AR.strStockStatus,
			TC.strTaxCode,
			dtmLastActivityDate = MAX(CE.dtmLastActivityDate),
			CE.strEquityType,
			dblEquity = SUM(CE.dblEquity),
			CE.intConcurrencyId 
	   FROM tblPATCustomerEquity CE
 INNER JOIN tblEMEntity ENT
		 ON ENT.intEntityId = CE.intCustomerId
 INNER JOIN tblPATRefundRate RR
		 ON RR.intRefundTypeId = CE.intRefundTypeId
 INNER JOIN tblGLFiscalYear FY
		 ON FY.intFiscalYearId = CE.intFiscalYearId
 INNER JOIN tblARCustomer AR
		 ON AR.intEntityCustomerId = CE.intCustomerId
  LEFT JOIN tblSMTaxCode TC
		 ON TC.intTaxCodeId = AR.intTaxCodeId
		 GROUP BY	CE.intCustomerId,
					ENT.strName,
					CE.intFiscalYearId,
					FY.strFiscalYear,
					AR.strStockStatus,
					TC.strTaxCode,
					CE.strEquityType,
					CE.intConcurrencyId
