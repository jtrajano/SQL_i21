CREATE VIEW [dbo].[vyuPATCustomerStatus]
		AS 
	SELECT ARC.intEntityCustomerId,
		   ENT.strName,
		   ARC.strStockStatus,
		   ARC.dtmLastActivityDate,
		   ARC.intConcurrencyId
	  FROM tblARCustomer ARC
INNER JOIN tblEntity ENT
		ON ENT.intEntityId = ARC.intEntityCustomerId
