CREATE VIEW [dbo].[vyuPATCalculateDividend]
	AS
SELECT DISTINCT intCustomerId = CS.intCustomerPatronId,
		ENT.strName,
		ARC.strStockStatus,
		APV.ysnWithholding,
		CS.dtmIssueDate,
		TC.strTaxCode,
		dtmLastActivityDate = ARC.dtmLastActivityDate
	FROM tblPATStockClassification SC
INNER JOIN tblPATCustomerStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.[intEntityId] = ENT.intEntityId
INNER JOIN tblAPVendor APV
	ON APV.[intEntityId] = CS.intCustomerPatronId
LEFT JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = ARC.intTaxCodeId
WHERE CS.strActivityStatus <> 'Retired'