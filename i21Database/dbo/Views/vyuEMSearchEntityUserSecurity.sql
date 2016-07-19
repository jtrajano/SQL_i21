CREATE VIEW [dbo].[vyuEMSearchEntityUserSecurity]
AS

SELECT 
        a.intEntityId,   
        a.strEntityNo, 
        a.strName,  
        g.strPhone,  
        e.strAddress,  
        e.strCity,  
        e.strState,  
        e.strZipCode,
        ysnActive = ~c.ysnDisabled,
		c.strUserName,
		h.intUserRoleID,
		strDefaultUserRole = h.strName,
		dtmLastLogin = u.dtmDate
    FROM         
            tblEMEntity a
        join [tblEMEntityType] b
            on b.intEntityId = a.intEntityId and b.strType = 'User'
        join tblSMUserSecurity c
            on c.intEntityUserSecurityId= a.intEntityId
        left join [tblEMEntityLocation] e  
            on ( ysnDefaultLocation = 1 )AND a.intEntityId = e.intEntityId
        left join [tblEMEntityToContact] f  
            on f.intEntityId = a.intEntityId and f.ysnDefaultContact = 1  
        left join tblEMEntity g  
            on f.intEntityContactId = g.intEntityId  
		left join tblSMUserRole h
			on h.intUserRoleID = c.intUserRoleID
		outer apply 
		(
			SELECT TOP 1 dtmDate FROM tblSMUserLogin u WHERE u.intEntityId = c.intEntityUserSecurityId ORDER BY dtmDate DESC
		) u