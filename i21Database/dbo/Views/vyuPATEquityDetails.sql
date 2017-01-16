CREATE VIEW [dbo].[vyuPATEquityDetails]
	AS 
SELECT	NEWID() as id,
		CE.intCustomerId,
		ENT.strName,
		CE.intFiscalYearId,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		dtmLastActivityDate = MAX(AR.dtmLastActivityDate),
		dblEquity = SUM(CASE WHEN CE.strEquityType = 'Undistributed' THEN CE.dblEquity ELSE 0 END),
		dblEquityReserve = SUM(CASE WHEN CE.strEquityType = 'Reserve' THEN CE.dblEquity ELSE 0 END),
		dblEquityPaid = SUM(CE.dblEquityPaid),
		CE.intConcurrencyId 
	FROM tblPATCustomerEquity CE
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CE.intCustomerId
INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CE.intFiscalYearId
INNER JOIN tblARCustomer AR
		ON AR.intEntityCustomerId = CE.intCustomerId
LEFT JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = AR.intTaxCodeId
		WHERE CE.dblEquity <> 0
GROUP BY CE.intCustomerId,
		ENT.strName,
		CE.intFiscalYearId,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		CE.intConcurrencyId