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
		dblEquityPaid = SUM(ISNULL(CE.dblEquityPaid,0)),
		ysnTransferable = CASE WHEN SUM(CASE WHEN CE.strEquityType = 'Undistributed' THEN CE.dblEquity ELSE 0 END) > SUM(CASE WHEN CE.strEquityType = 'Undistributed' THEN ISNULL(CE.dblEquityPaid,0) ELSE 0 END) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		ysnReserveTransferable = CASE WHEN SUM(CASE WHEN CE.strEquityType = 'Reserve' THEN CE.dblEquity ELSE 0 END) > SUM(CASE WHEN CE.strEquityType = 'Reserve' THEN ISNULL(CE.dblEquityPaid,0) ELSE 0 END) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM tblPATCustomerEquity CE
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CE.intCustomerId
INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CE.intFiscalYearId
INNER JOIN tblARCustomer AR
		ON AR.[intEntityId] = CE.intCustomerId
LEFT JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = AR.intTaxCodeId
		WHERE CE.dblEquity <> 0
GROUP BY CE.intCustomerId,
		ENT.strName,
		CE.intFiscalYearId,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode