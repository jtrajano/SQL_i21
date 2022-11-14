CREATE VIEW [dbo].[vyuQMSearchEntityUser]
AS
SELECT intUserId		= E.intEntityId
     , strEntityNo		= E.strEntityNo
	 , strUser			= E.strName
     , strPhone			= CON.strPhone
	 , strAddress		= EL.strAddress
	 , strCity			= EL.strCity
	 , strState			= EL.strState
	 , strZipCode		= EL.strZipCode
	 , ysnActive		= E.ysnActive
FROM tblEMEntity E
INNER JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId AND ET.strType = 'User'		
LEFT JOIN tblEMEntityLocation EL ON E.intEntityId = EL.intEntityId AND EL.ysnDefaultLocation = 1 
LEFT JOIN tblEMEntityToContact EC ON E.intEntityId = EC.intEntityId AND EC.ysnDefaultContact = 1  
LEFT JOIN tblEMEntity CON ON EC.intEntityContactId = CON.intEntityId