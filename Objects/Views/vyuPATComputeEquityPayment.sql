﻿CREATE VIEW [dbo].[vyuPATComputeEquityPayment]
	AS
SELECT	NEWID() as id,
		CE.intCustomerEquityId,
		intCustomerPatronId = CE.intCustomerId,
		EM.strName,
		RR.ysnQualified,
		dblEquityAvailable  = CE.dblEquity - CE.dblEquityPaid,
		CompLoc.intCompanyLocationId,
		dblWithholdPercent = CASE WHEN ISNULL(APV.ysnWithholding,0) = 1 THEN (CompLoc.dblWithholdPercent/100) ELSE 0 END
FROM tblPATCustomerEquity CE
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = CE.intCustomerId
LEFT OUTER JOIN tblAPVendor APV
	ON APV.intEntityId = CE.intCustomerId
INNER JOIN tblPATRefundRate RR
	ON RR.intRefundTypeId = CE.intRefundTypeId
CROSS APPLY (SELECT intCompanyLocationId,dblWithholdPercent FROM tblSMCompanyLocation) CompLoc