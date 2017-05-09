CREATE VIEW [dbo].[vyuPATCalculateDividend]
	AS
SELECT DISTINCT intCustomerId = CS.intCustomerPatronId,
		ENT.strName,
		FY.intFiscalYearId,
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
	ON ARC.intEntityCustomerId = ENT.intEntityId
INNER JOIN tblAPVendor APV
	ON APV.intEntityVendorId = CS.intCustomerPatronId
LEFT JOIN tblSMTaxCode TC
	ON TC.intTaxCodeId = ARC.intTaxCodeId
OUTER APPLY (
	SELECT intFiscalYearId
	FROM tblGLFiscalYear FY
	WHERE CS.dtmIssueDate BETWEEN FY.dtmDateFrom AND FY.dtmDateTo
) FY
WHERE CS.strActivityStatus <> 'Retired'