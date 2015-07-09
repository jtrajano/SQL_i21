﻿CREATE VIEW [dbo].[vyuARCustomerContacts]
AS
SELECT     
B.intEntityId AS intCustomerEntityId, 
A.[intEntityCustomerId],
--B2.intEntityId, 
--D.[intEntityContactId], 
--B2.strName, 
--B2.strEmail, 
D.intEntityId, 
D.intEntityId intEntityContactId, 
D.strName, 
D.strEmail, 
E.strLocationName, 
D.strPhone, 
D.strTimezone, 
D.strTitle, 
C.ysnPortalAccess,
D.ysnActive,
--CAST((CASE WHEN A.intDefaultContactId = C.intARCustomerToContactId THEN 'true' ELSE 'false' END) as bit) as ysnDefaultContact
C.ysnDefaultContact 
FROM dbo.tblARCustomer AS A INNER JOIN
	dbo.tblEntity AS B ON A.[intEntityCustomerId] = B.intEntityId INNER JOIN
	dbo.tblEntityToContact AS C ON A.[intEntityCustomerId] = C.[intEntityId] INNER JOIN
	--dbo.tblEntityContact AS D ON C.[intEntityContactId] = D.[intEntityContactId] INNER JOIN
	dbo.tblEntity AS D ON C.[intEntityContactId] = D.[intEntityId] LEFT OUTER JOIN
	--dbo.tblEntity AS B2 ON D.[intEntityContactId] = B2.intEntityId LEFT OUTER JOIN	
	dbo.tblEntityLocation AS E ON C.intEntityLocationId = E.intEntityLocationId