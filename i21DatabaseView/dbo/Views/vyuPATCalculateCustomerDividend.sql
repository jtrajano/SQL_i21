CREATE VIEW [dbo].[vyuPATCalculateCustomerDividend]
	AS
SELECT CS.intCustomerStockId,
	CS.intCustomerPatronId AS intCustomerId,
	CS.strStockStatus,
	CS.intStockId,
	SC.strStockName,
	CS.strCertificateNo,
	IssueStk.dtmIssueDate,
	CS.dblParValue,
	CS.dblSharesNo,
	SC.dblDividendsPerShare
	FROM tblPATStockClassification SC
INNER JOIN tblPATCustomerStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblPATIssueStock IssueStk
	ON IssueStk.intCustomerStockId = CS.intCustomerStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityId = ENT.intEntityId
WHERE CS.strActivityStatus = 'Open'