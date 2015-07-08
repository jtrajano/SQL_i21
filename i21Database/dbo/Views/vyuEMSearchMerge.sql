CREATE VIEW [dbo].[vyuEMSearchMerge]
AS 	
select 
	A.intEntityId,
	B.intEntityContactId,
	strEntityNo = A.strEntityNo,
	strEntityName = A.strName,
	strEmail = B.strEmail,
	strPhone =	B.strPhone,
	strContactName = B.strName,
	strAddress = C.strAddress,
	strZipCode = C.strZipCode,
	strEntityType = 
					STUFF((SELECT '; ' + t.strType
						FROM tblEntityType t
							WHERE t.intEntityId = A.intEntityId
								FOR XML PATH('')), 1, 1, '') 
	from tblEntity A
		JOIN vyuEMEntityContact B
			ON A.intEntityId = B.intEntityId
		JOIN tblEntityLocation C
			ON A.intEntityId = C.intEntityId
