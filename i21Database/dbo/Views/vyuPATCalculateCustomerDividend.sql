CREATE VIEW [dbo].[vyuPATCalculateCustomerDividend]
	AS
SELECT CS.intCustomerStockId,
	CS.intCustomerPatronId AS intCustomerId,
	NEWID() as id,
	CS.strStockStatus,
	CS.intStockId,
	SC.strStockName,
	CS.strCertificateNo,
	CS.dtmIssueDate,
	CS.dblParValue,
	CS.dblSharesNo,
	CS.ysnPosted,
	SC.dblDividendsPerShare
	FROM tblPATStockClassification SC
INNER JOIN tblPATIssueStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityId = ENT.intEntityId
WHERE CS.ysnPosted = 1