CREATE VIEW [dbo].[vyuEMSearchEntityUserSecurity]
AS

SELECT 
        a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
        strPhone = i.strPhone,  
		g.strEmail,
        e.strAddress,  
        e.strCity,  
        e.strState,  
        e.strZipCode,
        ysnActive = ~c.ysnDisabled,
		c.strUserName,
		h.intUserRoleID,
		strDefaultUserRole = h.strName,
		dtmLastLogin = u.dtmDate,
		ysnHasSMTP = Cast( case when isnull(j.intSMTPInformationId, 0) > 0 then 1 else 0 end as bit)
    FROM         
            tblEMEntity a
        join [tblEMEntityType] b
            on b.intEntityId = a.intEntityId and b.strType = 'User'
        join tblSMUserSecurity c
            on c.[intEntityId]= a.intEntityId
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
		left join tblEMEntitySMTPInformation j
			on g.intEntityId = j.intEntityId
		outer apply 
		(
			SELECT TOP 1 dtmDate FROM tblSMUserLogin u WHERE u.intEntityId = c.[intEntityId] ORDER BY dtmDate DESC
		) u