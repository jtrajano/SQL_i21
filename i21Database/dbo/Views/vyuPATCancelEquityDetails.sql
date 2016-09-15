CREATE VIEW [dbo].[vyuPATCancelEquityDetails]
	AS
SELECT	CED.intCancelDetailId,
		CED.intCancelId,
		CED.intFiscalYearId,
		FY.strFiscalYear,
		CED.intCustomerId,
		ENT.strName,
		CED.intRefundTypeId,
		RR.strRefundType,
		CED.dblQuantityAvailable,
		CED.strCancelBy,
		CED.dblCancelByPercentage,
		CED.dblQuantityCancelled,
		dblNewQuantity = ISNULL(CED.dblQuantityAvailable - CED.dblQuantityCancelled, 0),
		CED.intConcurrencyId
	FROM tblPATCancelEquityDetail CED
	INNER JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = FY.intFiscalYearId
	INNER JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = CED.intRefundTypeId
	INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CED.intCustomerId
GO