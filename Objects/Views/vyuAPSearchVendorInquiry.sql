CREATE VIEW [dbo].[vyuAPSearchVendorInquiry]
AS

SELECT TOP 100 PERCENT
	entity.intEntityId
	,entity.strName
	,CASE WHEN vendor.strVendorId = '' THEN entity.strEntityNo ELSE vendor.strVendorId END AS strEntityNo
	,entityContact.strPhone
	,entityContact.strEmail
	,entityContact.strMobile
	,entityContact.strName AS strContactName
FROM dbo.tblAPVendor vendor
INNER JOIN dbo.tblEMEntity entity ON vendor.intEntityId = entity.intEntityId
INNER JOIN dbo.tblEMEntityToContact entityToContact ON entityToContact.intEntityId = entity.intEntityId
INNER JOIN dbo.tblEMEntity entityContact
		ON entityToContact.intEntityContactId = entityContact.intEntityId AND entityToContact.ysnDefaultContact = 1
ORDER BY entity.strName
