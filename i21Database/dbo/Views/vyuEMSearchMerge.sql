CREATE VIEW [dbo].[vyuEMSearchMerge]
AS 	
select 
	A.intEntityId,
	AB.intEntityContactId,
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
	JOIN tblEntityToContact AB
		ON A.intEntityId = AB.intEntityId and AB.ysnDefaultContact = 1
	JOIN tblEntity B
		ON AB.intEntityContactId = B.intEntityId
	JOIN tblEntityLocation C
		ON A.intEntityId = C.intEntityId and C.ysnDefaultLocation = 1
	JOIN tblEntityType D
		ON A.intEntityId = D.intEntityId
