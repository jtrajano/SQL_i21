CREATE VIEW [dbo].[vyuEME2C2Role]
	AS 

	select 
		intEntityToContactId	=	a.intEntityToContactId,
		intEntityId				=	a.intEntityId, 
		strEntityNo				=	c.strEntityNo,
		strEntityName			=	c.strName,
		intEntityContactId		=	a.intEntityContactId, 
		strEntityContactName	=	d.strName,
		intEntityRoleId			=	a.intEntityRoleId, 
		strRoleName				=	b.strName,
		ysnAdmin				=	b.ysnAdmin,
		strPassword				=	e.strPassword
	from tblEntityToContact a
		join tblSMUserRole b
			on a.intEntityRoleId = b.intUserRoleID
		join tblEntity c
			on a.intEntityId = c.intEntityId
		join tblEntity d
			on a.intEntityContactId = d.intEntityId
		left join tblEntityCredential e
			on a.intEntityContactId = e.intEntityId
