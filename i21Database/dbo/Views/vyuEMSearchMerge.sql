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
	strEntityType = D.strType,
	strEntityNoType = Replace(A.strEntityNo,' ','') + ' ' + D.strType 
	from tblEntity A
		JOIN vyuEMEntityContact B
			ON A.intEntityId = B.intEntityId
		JOIN tblEntityLocation C
			ON A.intEntityId = C.intEntityId
		JOIN tblEntityType D
			ON D.intEntityId = A.intEntityId
