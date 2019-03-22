CREATE VIEW [dbo].[vyuPATCancel]
	AS 
SELECT	CE.intCancelEquityId,
		CE.dtmCancelDate,
		CE.strCancelNo,
		CE.strDescription,
		CE.strCancelBy,
		CE.dblCancelByValue,
		CE.ysnPosted,
		CE.intConcurrencyId,
		CED.intCancelEquityDetailId,
		CED.intFiscalYearId,
		FY.strFiscalYear,
		CED.intCustomerId,
		ENT.strName,
		RR.strRefundDescription,
		CED.dblQuantityAvailable,
		CED.dblQuantityCancelled,
		dblNewQuantity = CED.dblQuantityAvailable - CED.dblQuantityCancelled
	  FROM tblPATCancelEquity CE
INNER JOIN tblPATCancelEquityDetail CED
		ON CED.intCancelEquityId = CE.intCancelEquityId
 LEFT JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CED.intFiscalYearId
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = CED.intCustomerId
 LEFT JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = CED.intRefundTypeId