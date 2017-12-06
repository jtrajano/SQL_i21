CREATE VIEW [dbo].[vyuPATCalculateCustomerDividend]
	AS
SELECT IssueStk.intCustomerStockId,
	IssueStk.intCustomerPatronId AS intCustomerId,
	NEWID() as id,
	IssueStk.strStockStatus,
	IssueStk.intStockId,
	SC.strStockName,
	IssueStk.strCertificateNo,
	IssueStk.dtmIssueDate,
	IssueStk.dblParValue,
	IssueStk.dblSharesNo,
	IssueStk.ysnPosted,
	SC.dblDividendsPerShare
	FROM tblPATStockClassification SC
INNER JOIN tblPATIssueStock IssueStk
	ON IssueStk.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = IssueStk.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityId = ENT.intEntityId
WHERE IssueStk.ysnPosted = 1