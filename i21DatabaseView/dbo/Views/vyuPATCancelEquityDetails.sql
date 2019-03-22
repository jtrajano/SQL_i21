CREATE VIEW [dbo].[vyuPATCancelEquityDetails]
	AS
SELECT	CED.intCancelEquityDetailId,
		CED.intCancelEquityId,
		CED.intFiscalYearId,
		FY.strFiscalYear,
		CED.intCustomerId,
		ENT.strName,
		CED.strEquityType,
		CED.intRefundTypeId,
		RR.strRefundType,
		CED.dblQuantityAvailable,
		CED.dblQuantityCancelled,
		dblNewQuantity = ISNULL(CED.dblQuantityAvailable - CED.dblQuantityCancelled, 0),
		CED.intConcurrencyId
	FROM tblPATCancelEquityDetail CED
	INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CED.intFiscalYearId
	INNER JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = CED.intRefundTypeId
	INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CED.intCustomerId