CREATE VIEW [dbo].[vyuPATCustomerStatus]
		AS 
	SELECT ARC.[intEntityId],
		   ENT.strName,
		   ARC.strStockStatus,
		   ARC.dtmLastActivityDate,
		   ARC.intConcurrencyId
	  FROM tblARCustomer ARC
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = ARC.[intEntityId]
