﻿CREATE VIEW [dbo].[vyuEMSearchMerge]
AS 	
select 
	A.intEntityId,
	AB.intEntityContactId,
	strEntityNo = A.strEntityNo,
	strEntityName = A.strName,
	strEmail = B.strEmail,
	strPhone =	phone.strPhone,
	strContactName = B.strName,
	strAddress = C.strAddress,
	strZipCode = C.strZipCode,
	strEntityType = D.strType,
	strEntityNoType = Replace(A.strEntityNo,' ','') + ' ' + D.strType,
	strEntityIdType = CAST(A.intEntityId as nvarchar) + ' ' + D.strType
	from tblEMEntity A	
	JOIN [tblEMEntityToContact] AB
		ON A.intEntityId = AB.intEntityId and AB.ysnDefaultContact = 1
	JOIN tblEMEntity B
		ON AB.intEntityContactId = B.intEntityId
	JOIN [tblEMEntityLocation] C
		ON A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
	JOIN [tblEMEntityType] D
		ON A.intEntityId = D.intEntityId -- and D.strType in ('Vendor', 'Customer')	
	LEFT JOIN tblEMEntityPhoneNumber phone
		ON phone.intEntityId = B.intEntityId
