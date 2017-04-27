CREATE VIEW [dbo].[vyuPATEquityRefundDetails]
	AS
SELECT	CE.intCustomerEquityId,
		CE.intFiscalYearId,
		FY.strFiscalYear,
		CE.intRefundTypeId,
		CE.strEquityType,
		CE.intCustomerId,
		EM.strName,
		strRefundType = ISNULL(RR.strRefundType, ''),
		CE.dblEquity,
		dblEquityPaid = ISNULL(CE.dblEquityPaid,0),
		dblEquityAvailable = CE.dblEquity - ISNULL(CE.dblEquityPaid,0),
		CE.intConcurrencyId,
		ysnQualified = CASE WHEN ISNULL(RR.ysnQualified, 0) = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM tblPATCustomerEquity CE
	LEFT JOIN tblPATRefundRate RR
		ON CE.intRefundTypeId = RR.intRefundTypeId
	INNER JOIN tblGLFiscalYear FY
		ON CE.intFiscalYearId = FY.intFiscalYearId
	INNER JOIN tblEMEntity EM
		ON CE.intCustomerId = EM.intEntityId