﻿CREATE VIEW [dbo].[vyuARCustomerContacts]
AS
SELECT     
B.intEntityId AS intCustomerEntityId, 
A.[intEntityId],
D.intEntityId AS intEntityContactId, 
D.strName, 
D.strEmail, 
E.strLocationName, 
EnPhoneNo.strPhone,
D.strMobile,
D.strTimezone, 
D.strTitle,
D.strEmailDistributionOption,
C.ysnPortalAccess,
D.ysnActive,
D.ysnReceiveEmail,
C.ysnDefaultContact,
intWarehouseId = ISNULL(G.intCompanyLocationId, -99)
FROM dbo.tblARCustomer AS A INNER JOIN
	dbo.tblEMEntity AS B ON A.[intEntityId] = B.intEntityId INNER JOIN
	dbo.[tblEMEntityToContact] AS C ON A.[intEntityId] = C.intEntityId INNER JOIN
	dbo.tblEMEntity AS D ON C.intEntityContactId = D.intEntityId LEFT OUTER JOIN
	dbo.tblEMEntityPhoneNumber as EnPhoneNo ON C.[intEntityContactId] = EnPhoneNo.[intEntityId] LEFT OUTER JOIN
	dbo.[tblEMEntityLocation] AS E ON C.intEntityLocationId = E.intEntityLocationId
	LEFT JOIN tblEMEntityLocation F ON A.intEntityId = F.intEntityId AND F.ysnDefaultLocation = 1
	LEFT JOIN (SELECT intCompanyLocationId FROM tblSMCompanyLocation) G ON F.intWarehouseId = G.intCompanyLocationId