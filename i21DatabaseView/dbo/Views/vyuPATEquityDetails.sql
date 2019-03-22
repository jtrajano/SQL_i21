CREATE VIEW [dbo].[vyuPATEquityDetails]
	AS 
SELECT	id = CAST(ROW_NUMBER() OVER(ORDER BY FY.dtmDateFrom DESC, ENT.strName) AS int),
		CE.intCustomerId,
		ENT.strEntityNo,
		ENT.strName,
		CE.intFiscalYearId,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode,
		dtmLastActivityDate = MAX(AR.dtmLastActivityDate),
		dblQualifiedEquity = SUM(CE.dblQualfiedEquity),
		dblNonQualifiedEquity = SUM(CE.dblNonQualifiedEquity),
		dblEquityReserve = SUM(CE.dblEquityReserve),
		dblEquityPaid = SUM(CE.dblEquityPaid),
		dblEquityTotal = SUM(CE.dblQualfiedEquity + CE.dblNonQualifiedEquity + CE.dblEquityReserve),
		ysnTransferable = CASE 
								WHEN SUM(CE.dblQualfiedEquity + CE.dblNonQualifiedEquity) > 0 
								THEN CAST(1 AS BIT) 
								ELSE CAST(0 AS BIT) 
							END,
		ysnReserveTransferable = CASE 
									WHEN SUM(dblEquityReserve) > 0 
									THEN CAST(1 AS BIT) 
									ELSE CAST(0 AS BIT) 
								END
	FROM (SELECT	Equity.intFiscalYearId,
					Equity.intCustomerId,
					Equity.strEquityType,
					dblQualfiedEquity		= CASE WHEN RR.ysnQualified = 1 AND Equity.strEquityType != 'Reserve' THEN Equity.dblEquity - Equity.dblEquityPaid ELSE 0 END,
					dblNonQualifiedEquity	= CASE WHEN RR.ysnQualified = 0 AND Equity.strEquityType != 'Reserve' THEN Equity.dblEquity - Equity.dblEquityPaid ELSE 0 END,
					dblEquityReserve		= CASE WHEN Equity.strEquityType = 'Reserve' THEN Equity.dblEquity - Equity.dblEquityPaid ELSE 0 END,
					dblEquityPaid			= Equity.dblEquityPaid
		FROM tblPATCustomerEquity Equity
		INNER JOIN tblPATRefundRate RR
			ON RR.intRefundTypeId = Equity.intRefundTypeId
		WHERE Equity.dblEquity <> 0
	) CE
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CE.intCustomerId
INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CE.intFiscalYearId
INNER JOIN tblARCustomer AR
		ON AR.intEntityId = CE.intCustomerId
LEFT JOIN tblSMTaxCode TC
		ON TC.intTaxCodeId = AR.intTaxCodeId
GROUP BY CE.intCustomerId,
		ENT.strEntityNo,
		ENT.strName,
		CE.intFiscalYearId,
		FY.dtmDateFrom,
		FY.strFiscalYear,
		AR.strStockStatus,
		TC.strTaxCode