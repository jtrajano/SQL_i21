CREATE VIEW [dbo].[vyuPATCancel]
	AS 
	SELECT CE.intCancelId,
		   CE.dtmCancelDate,
		   CE.strCancelNo,
		   CE.strDescription,
		   CE.intFromCustomerId,
		   CE.intToCustomerId,
		   CE.intFiscalYearId AS intFiscalYearSearch,
		   CE.strCancelBy AS strCancelBySearch,
		   CE.dblCancelByAmount,
		   CE.dblCancelLessAmount,
		   CE.intIncludeEquityReserve,
		   CE.ysnPosted,
		   CE.intConcurrencyId,
		   CED.intCancelDetailId,
		   CED.intFiscalYearId,
		   FY.strFiscalYear,
		   CED.intCustomerId,
		   ENT.strName,
		   RR.strRefundDescription,
		   CED.dblQuantityAvailable,
		   CED.strCancelBy,
		   CED.dblCancelByPercentage,
		   CED.dblQuantityCancelled,
		   dblNewQuantity = CED.dblQuantityAvailable - CED.dblQuantityCancelled
	  FROM tblPATCancelEquity CE
INNER JOIN tblPATCancelEquityDetail CED
		ON CED.intCancelId = CE.intCancelId
 LEFT JOIN tblGLFiscalYear FY
		ON FY.intFiscalYearId = CED.intFiscalYearId
INNER JOIN tblEntity ENT
		ON ENT.intEntityId = CED.intCustomerId
 LEFT JOIN tblPATRefundRate RR
		ON RR.intRefundTypeId = CED.intRefundTypeId
GO

