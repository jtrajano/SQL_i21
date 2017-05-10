CREATE VIEW [dbo].[vyuPATCalculateCustomerDividend]
	AS
SELECT CS.intCustomerStockId,
	CS.intCustomerPatronId AS intCustomerId,
	NEWID() as id,
	CS.intStockId,
	SC.strStockName,
	CS.strCertificateNo,
	CS.dtmIssueDate,
	SC.dblParValue,
	CS.dblSharesNo,
	SC.intDividendsPerShare
	FROM tblPATStockClassification SC
INNER JOIN tblPATCustomerStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityId = ENT.intEntityId
WHERE CS.strActivityStatus = 'Open'
