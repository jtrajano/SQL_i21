CREATE VIEW [dbo].[vyuPATCalculateDividend]
	AS
SELECT	id = CAST(ROW_NUMBER() OVER (ORDER BY CS.intCustomerStockId) AS INT),
		intCustomerId = CS.intCustomerPatronId,
		ENT.strEntityNo,
		ENT.strName,
		IssueStk.dtmIssueDate,
		CS.strStockStatus,
		CS.strActivityStatus,
		ysnWithholding = ISNULL(APV.ysnWithholding, 0),
		TC.strTaxCode,
		dtmLastActivityDate = ARC.dtmLastActivityDate,
		IssueStk.ysnPosted,
		SC.intStockId,
		SC.strStockName,
		SC.dblDividendsPerShare,
		CS.dblParValue,
		CS.dblSharesNo,
		CS.dblFaceValue
	FROM tblPATStockClassification SC
INNER JOIN tblPATIssueStock IssueStk
	ON IssueStk.intStockId = SC.intStockId
INNER JOIN tblPATCustomerStock CS
	ON CS.intCustomerStockId = IssueStk.intCustomerStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.[intEntityId] = ENT.intEntityId
LEFT JOIN tblAPVendor APV
	ON APV.[intEntityId] = CS.intCustomerPatronId
LEFT JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = ARC.intTaxCodeId
WHERE IssueStk.ysnPosted = 1 AND CS.strActivityStatus NOT IN ('Xferred','Retired')