CREATE VIEW [dbo].[vyuPATTransfer]
	AS 
	SELECT  PT.intTransferId,
		    PT.strTransferNo,
			PT.dtmTransferDate,
			PT.strTransferType,
			PTD.intTransferorId,
			strTransferorName = (SELECT DISTINCT strName FROM tblEntity WHERE intEntityId = PTD.intTransferorId),
			PTD.strCertificateNo,
			PTD.strStockName,
			PTD.dblQuantityAvailable,
			PTD.intTransfereeId,
			strTransfereeName = (SELECT DISTINCT strName FROM tblEntity WHERE intEntityId = PTD.intTransfereeId),
			PTD.strToCertificateNo,
			PTD.strToStockName,
			PTD.dblQuantityTransferred,
			PT.intConcurrencyId
		FROM tblPATTransfer PT
INNER JOIN tblPATTransferDetail PTD
		ON PT.intTransferId = PTD.intTransferId


