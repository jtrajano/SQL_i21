CREATE VIEW [dbo].[vyuPATCustomerStock]
	AS
SELECT	CS.intCustomerStockId,
		CS.intCustomerPatronId,
		C.strName AS strCustomerPatronId,
		CS.intStockId,
		PC.strStockName,
		CS.strCertificateNo,
		CS.strStockStatus,
		CS.dblSharesNo,
		CS.dtmRetireDate,
		CS.dtmIssueDate,
		CS.strActivityStatus,
		CS.strCheckNumber,
		CS.dtmCheckDate,
		CS.dblCheckAmount,
		CS.intTransferredFrom,
		CT.strName AS strTransferredFrom,
		CS.dtmTransferredDate,
		CS.dblParValue,
		CS.dblFaceValue,
		CS.ysnPosted,
		CS.intConcurrencyId
	FROM tblPATCustomerStock CS
	INNER JOIN tblEMEntity C
		ON C.intEntityId = CS.intCustomerPatronId
	INNER JOIN tblPATStockClassification PC
		ON PC.intStockId = CS.intStockId
	LEFT OUTER JOIN tblEMEntity CT
		ON CT.intEntityId = CS.intTransferredFrom
GO