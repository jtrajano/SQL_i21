CREATE VIEW [dbo].[vyuPATEquityDetails]
	AS 
SELECT	CE.intCustomerId,
		ENT.strName,
		CE.intFiscalYearId,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		RR.intRefundTypeId,
		RR.strRefundType,
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
WHERE CE.dblEquity <> 0
		GROUP BY	CE.intCustomerId,
				ENT.strName,
				CE.intFiscalYearId,
				RR.intRefundTypeId,
				RR.strRefundType,
				FY.strFiscalYear,
				AR.strStockStatus,
				TC.strTaxCode,
				CE.strEquityType,
				CE.intConcurrencyId