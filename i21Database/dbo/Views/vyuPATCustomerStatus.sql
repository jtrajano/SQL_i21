CREATE VIEW [dbo].[vyuPATCustomerStatus]
		AS 
	SELECT ARC.intEntityCustomerId,
		   ENT.strName,
		   ARC.strStockStatus,
		   ARC.dtmLastActivityDate,
		   ARC.intConcurrencyId
	  FROM tblARCustomer ARC
INNER JOIN tblEMEntity ENT
		ON ENT.intEntityId = ARC.intEntityCustomerId
