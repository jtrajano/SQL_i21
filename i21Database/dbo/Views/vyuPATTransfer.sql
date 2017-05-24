CREATE VIEW [dbo].[vyuPATTransfer]
	AS
WITH PTD (
	intTransferDetailId,
	intTransferId,
	intTransferorId,
	strTransferorName,
	strEquityType,
	intFiscalYearId,
	strTransferorFiscal,
	intPatronageCategoryId,
	strCategoryCode,
	intRefundTypeId,
	strTransferorRefundType,
	intCustomerStockId,
	dtmIssueDate,
    strStockStatus,
    dblParValue,
    strCertificateNo,
    strStockName,
    intTransfereeId,
	strTransfereeName,
	intToStockId,
	strToStockName,
	intToFiscalYearId,
	strTransfereeFiscal,
	strToStockStatus,
	strToCertificateNo,
	dtmToIssueDate,
	intToRefundTypeId,
	strTransfereeRefundType,
	dblTransferPercentage,
	dblQuantityAvailable,
	dblQuantityTransferred,
	intConcurrencyId
) AS (
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
	LEFT OUTER JOIN tblEMEntity transferee
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
		ON transfereeFY.intFiscalYearId = TD.intFiscalYearId
	LEFT OUTER JOIN tblGLFiscalYear transferorFY
		ON transferorFY.intFiscalYearId = TD.intToFiscalYearId
	LEFT OUTER JOIN tblPATRefundRate transfereeRR
		ON transfereeRR.intRefundTypeId = TD.intToRefundTypeId
	LEFT OUTER JOIN tblPATRefundRate transferorRR
		ON transferorRR.intRefundTypeId = TD.intRefundTypeId
)
SELECT	NEWID() AS id,
		PT.intTransferId,
		PT.strTransferNo,
		PT.dtmTransferDate,
		PT.intTransferType,
		T.strTransferType,
		PT.strTransferDescription,
		PT.ysnPosted,
		PTD.intTransferorId,
		PTD.strTransferorName,
		PTD.strEquityType,
		PTD.strTransferorRefundType AS strRefundType,
		PTD.strCertificateNo,
		PTD.strStockName,
		PTD.dblQuantityAvailable,
		PTD.intTransfereeId,
		PTD.strTransfereeName,
		PTD.strToCertificateNo,
		PTD.strToStockName,
		PTD.dblQuantityTransferred,
		PTD.strTransfereeFiscal AS strFiscalYear,
		PT.intConcurrencyId
	FROM tblPATTransfer PT
	INNER JOIN PTD
		ON PTD.intTransferId = PT.intTransferId
	INNER JOIN tblPATTransferType T
		ON T.intTransferType = PT.intTransferType