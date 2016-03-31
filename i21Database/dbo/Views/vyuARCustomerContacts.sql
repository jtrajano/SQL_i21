﻿CREATE VIEW [dbo].[vyuARCustomerContacts]
AS
SELECT     
B.intEntityId AS intCustomerEntityId, 
A.intEntityCustomerId,
D.intEntityId, 
D.intEntityId AS intEntityContactId, 
D.strName, 
D.strEmail, 
E.strLocationName, 
D.strPhone, 
D.strTimezone, 
D.strTitle,
D.strEmailDistributionOption,
C.ysnPortalAccess,
D.ysnActive,
D.ysnReceiveEmail,
C.ysnDefaultContact 
FROM dbo.tblARCustomer AS A INNER JOIN
	dbo.tblEMEntity AS B ON A.intEntityCustomerId = B.intEntityId INNER JOIN
	dbo.[tblEMEntityToContact] AS C ON A.intEntityCustomerId = C.intEntityId INNER JOIN
	dbo.tblEMEntity AS D ON C.intEntityContactId = D.intEntityId LEFT OUTER JOIN
	dbo.[tblEMEntityLocation] AS E ON C.intEntityLocationId = E.intEntityLocationId