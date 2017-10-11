CREATE VIEW [dbo].[vyuPATCalculateDividend]
	AS
SELECT	id = NEWID(),
		intCustomerId = CS.intCustomerPatronId,
		ENT.strEntityNo,
		ENT.strName,
		CS.dtmIssueDate,
		CS.strStockStatus,
		CS.strActivityStatus,
		ysnWithholding = ISNULL(APV.ysnWithholding, 0),
		TC.strTaxCode,
		dtmLastActivityDate = ARC.dtmLastActivityDate,
		CS.ysnPosted,
		SC.intStockId,
		SC.strStockName,
		SC.dblDividendsPerShare,
		CS.dblParValue,
		CS.dblSharesNo,
		CS.dblFaceValue
	FROM tblPATStockClassification SC
INNER JOIN tblPATCustomerStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.[intEntityId] = ENT.intEntityId
LEFT JOIN tblAPVendor APV
	ON APV.[intEntityId] = CS.intCustomerPatronId
LEFT JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = ARC.intTaxCodeId
WHERE CS.ysnPosted = 1 AND CS.strActivityStatus NOT IN ('Xferred','Retired')