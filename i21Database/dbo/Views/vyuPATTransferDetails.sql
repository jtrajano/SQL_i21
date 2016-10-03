CREATE VIEW [dbo].[vyuPATTransferDetails]
	AS
SELECT	TD.intTransferDetailId,
		TD.intTransferId,
		TD.intTransferorId,
		transferor.strName AS strTransferorName,
		TD.strEquityType,
		TD.intFiscalYearId,
		transferorFY.strFiscalYear AS strTransferorFiscal,
		TD.intPatronageCategoryId,
		PC.strCategoryCode,
		TD.intRefundTypeId,
		transferorRR.strRefundType AS strTransferorRefundType,
		TD.intCustomerStockId,
		CS.dtmIssueDate,
        CS.strStockStatus,
        TD.dblParValue,
        CS.strCertificateNo,
        CS.strStockName,
        TD.intTransfereeId,
		transferee.strName AS strTransfereeName,
		TD.intToStockId,
		SC.strStockName AS strToStockName,
		TD.intToFiscalYearId,
		transfereeFY.strFiscalYear AS strTransfereeFiscal,
		TD.strToStockStatus,
		TD.strToCertificateNo,
		TD.dtmToIssueDate,
		TD.intToRefundTypeId,
		transfereeRR.strRefundType AS strTransfereeRefundType,
		TD.dblTransferPercentage,
		TD.dblQuantityAvailable,
		TD.dblQuantityTransferred,
		TD.intConcurrencyId
	FROM tblPATTransferDetail TD
	INNER JOIN tblEMEntity transferor
		ON transferor.intEntityId = TD.intTransferorId
	INNER JOIN tblEMEntity transferee
		ON transferee.intEntityId = TD.intTransfereeId
	LEFT OUTER JOIN (SELECT iCS.intCustomerStockId,iCS.dtmIssueDate, iCS.dblParValue, iCS.strStockStatus, iCS.strCertificateNo, iSC.strStockName
						FROM tblPATCustomerStock iCS INNER JOIN tblPATStockClassification iSC 
						ON iCS.intStockId = iSC.intStockId) CS
		ON CS.intCustomerStockId = TD.intCustomerStockId
	LEFT OUTER JOIN tblPATStockClassification SC
		ON SC.intStockId = TD.intToStockId
	LEFT OUTER JOIN tblPATPatronageCategory PC
		ON PC.intPatronageCategoryId = TD.intPatronageCategoryId
	LEFT OUTER JOIN tblGLFiscalYear transfereeFY
		ON transfereeFY.intFiscalYearId = TD.intToFiscalYearId
	LEFT OUTER JOIN tblGLFiscalYear transferorFY
		ON transferorFY.intFiscalYearId = TD.intFiscalYearId
	LEFT OUTER JOIN tblPATRefundRate transfereeRR
		ON transfereeRR.intRefundTypeId = TD.intRefundTypeId
	LEFT OUTER JOIN tblPATRefundRate transferorRR
		ON transferorRR.intRefundTypeId = TD.intToRefundTypeId
GO