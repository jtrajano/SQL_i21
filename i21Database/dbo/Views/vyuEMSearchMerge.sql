CREATE VIEW [dbo].[vyuEMSearchMerge]
AS 	
SELECT 
A.intEntityId,
AB.intEntityContactId,
strEntityNo = A.strEntityNo,
strLocation = C.strLocationName,
strEntityName = A.strName,
strEmail = B.strEmail,
strPhone =	E.strPhone,
strContactName = B.strName,
strAddress = C.strAddress,
strZipCode = C.strZipCode,
strEntityType = D.strType,
strEntityNoType = REPLACE(A.strEntityNo,' ','') + ' ' + D.strType,
strEntityIdType = CAST(A.intEntityId AS NVARCHAR) + ' ' + D.strType,
strLineOfBusiness = dbo.fnEMGetEntityLineOfBusiness(A.intEntityId)
FROM tblEMEntity A	
JOIN [tblEMEntityToContact] AB
	ON A.intEntityId = AB.intEntityId and AB.ysnDefaultContact = 1
JOIN tblEMEntity B
	ON AB.intEntityContactId = B.intEntityId
JOIN [tblEMEntityLocation] C
	ON A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
JOIN [tblEMEntityType] D
	ON A.intEntityId = D.intEntityId -- and D.strType in ('Vendor', 'Customer')
LEFT JOIN tblEMEntityPhoneNumber E
	ON E.intEntityId = B.intEntityId
