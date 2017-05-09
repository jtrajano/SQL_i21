CREATE VIEW [dbo].[vyuPATCalculateCustomerDividend]
	AS
SELECT CS.intCustomerStockId,
	CS.intCustomerPatronId AS intCustomerId,
	NEWID() as id,
	FY.intFiscalYearId,
	CS.intStockId,
	SC.strStockName,
	CS.strCertificateNo,
	CS.dtmIssueDate,
	SC.dblParValue,
	CS.dblSharesNo,
	CS.ysnPosted,
	SC.intDividendsPerShare
	FROM tblPATStockClassification SC
INNER JOIN tblPATCustomerStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityCustomerId = ENT.intEntityId
OUTER APPLY(
	SELECT intFiscalYearId
	FROM tblGLFiscalYear FY
	WHERE  CS.dtmIssueDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
) FY