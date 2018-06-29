CREATE VIEW [dbo].[vyuSMIdentityUserInfo]

AS

SELECT
    B.intEntityId,
    B.strName AS strEntityName,
    D.intEntityId AS intEntityContactId,
    D.strName,
    D.strEmail,
    E.strLocationName,
    phone.strPhone AS strPhone,
    phone.strPhoneLookUp AS strPhoneLookup,
    mob.strPhone AS strMobile,
    mob.strPhoneLookUp AS strMobileLookup,
    E.strTimezone,
    D.strTitle,
    C.ysnPortalAccess,
    D.ysnActive,
    C.ysnDefaultContact
FROM
    dbo.tblEMEntity AS B INNER JOIN
    dbo.tblEMEntityToContact AS C ON B.intEntityId = C.intEntityId INNER JOIN
    dbo.tblEMEntity AS D ON C.intEntityContactId = D.intEntityId LEFT OUTER JOIN
    dbo.tblEMEntityPhoneNumber AS phone ON phone.intEntityId = D.intEntityId LEFT OUTER JOIN
    dbo.tblEMEntityMobileNumber AS mob ON mob.intEntityId = D.intEntityId LEFT OUTER JOIN
    dbo.tblEMEntityLocation AS E ON C.intEntityLocationId = E.intEntityLocationId
WHERE C.ysnDefaultContact = 1
