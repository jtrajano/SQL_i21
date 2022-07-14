CREATE VIEW [dbo].[vyuSMUserList]
AS

SELECT 
	a.intEntityId,   
    a.strName,  
	strUserId = c.strUserName,
	a.strExternalERPId,
    g.strEmail,
	strPhone = i.strPhone,  
	a.strMobile,
	strContactName = g.strName,
	e.strLocationName,
    e.strAddress,  
    e.strCity,  
    e.strState,  
    e.strZipCode,
	strCountry = (SELECT strCountry FROM dbo.tblSMCountry WHERE intCountryID = g.intDefaultCountryId),
	strUserRole = (SELECT strName FROM dbo.tblSMUserRole WHERE intUserRoleID = c.intUserRoleID),
    ysnActive = ~c.ysnDisabled
FROM         
        tblEMEntity a
    join [tblEMEntityType] b
        on b.intEntityId = a.intEntityId and b.strType = 'User'
    join tblSMUserSecurity c
        on c.[intEntityId]= a.intEntityId
	join tblEMEntityCredential d
        on d.intEntityId= a.intEntityId
    left join [tblEMEntityLocation] e  
        on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
    left join [tblEMEntityToContact] f  
        on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
    left join tblEMEntity g  
        on f.intEntityContactId = g.intEntityId  
	left join tblSMUserRole h
		on h.intUserRoleID = c.intUserRoleID
	left join tblEMEntityPhoneNumber i
		on i.intEntityId = g.intEntityId
	outer apply 
	(
		SELECT TOP 1 dtmDate, strResult FROM tblSMUserLogin u WHERE u.intEntityId = c.[intEntityId] ORDER BY dtmDate DESC
	) u