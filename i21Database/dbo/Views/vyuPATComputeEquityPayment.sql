CREATE VIEW [dbo].[vyuPATComputeEquityPayment]
	AS
SELECT	NEWID() as id,
		CE.intCustomerEquityId,
		intCustomerPatronId = CE.intCustomerId,
		EM.strName,
		dblEquityAvailable  = CE.dblEquity - CE.dblEquityPaid,
		CompLoc.intCompanyLocationId,
		dblWithholdPercent = CASE WHEN APV.ysnWithholding = 1 THEN (CompLoc.dblWithholdPercent/100) ELSE 0 END
FROM tblPATCustomerEquity CE
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = CE.intCustomerId
INNER JOIN tblAPVendor APV
	ON APV.[intEntityId] = CE.intCustomerId
CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) CompLoc