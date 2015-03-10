CREATE VIEW [dbo].[vyuARCustomerContacts]
AS
SELECT     
B.intEntityId AS intCustomerEntityId, 
A.intCustomerId,
B2.intEntityId, 
D.intContactId, 
B2.strName, 
B2.strEmail, 
E.strLocationName, 
D.strPhone, 
D.strTimezone, 
D.strTitle, 
C.ysnPortalAccess,
D.ysnActive,
CAST((CASE WHEN A.intDefaultContactId = C.intARCustomerToContactId THEN 'true' ELSE 'false' END) as bit) as ysnDefaultContact
FROM dbo.tblARCustomer AS A INNER JOIN
	dbo.tblEntity AS B ON A.intEntityId = B.intEntityId INNER JOIN
	dbo.tblARCustomerToContact AS C ON A.intCustomerId = C.intCustomerId INNER JOIN
	dbo.tblEntityContact AS D ON C.intContactId = D.intContactId INNER JOIN
	dbo.tblEntity AS B2 ON D.intEntityId = B2.intEntityId LEFT OUTER JOIN
	dbo.tblEntityLocation AS E ON C.intEntityLocationId = E.intEntityLocationId