CREATE VIEW [dbo].[vyuPATEquityDetails]
	AS 
	 SELECT CE.intCustomerEquityId,
			CE.intRefundTypeId,
			RR.strRefundType,
			CE.intCustomerId,
			ENT.strName,
			CE.intFiscalYearId,
			FY.strFiscalYear,
			AR.strStockStatus,
			TC.strTaxCode,
			CE.dtmLastActivityDate,
			CE.strEquityType,
			CE.dblEquity,
			CE.intConcurrencyId 
	   FROM tblPATCustomerEquity CE
 INNER JOIN tblEntity ENT
		 ON ENT.intEntityId = CE.intCustomerId
 INNER JOIN tblPATRefundRate RR
		 ON RR.intRefundTypeId = CE.intRefundTypeId
 INNER JOIN tblGLFiscalYear FY
		 ON FY.intFiscalYearId = CE.intFiscalYearId
 INNER JOIN tblARCustomer AR
		 ON AR.intEntityCustomerId = CE.intCustomerId
  LEFT JOIN tblSMTaxCode TC
		 ON TC.intTaxCodeId = AR.intTaxCodeId
