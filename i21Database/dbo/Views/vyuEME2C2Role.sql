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
		ysnPortalAdmin			=	a.ysnPortalAdmin,
		strPassword				=	e.strPassword
	from [tblEMEntityToContact] a
		join tblSMUserRole b
			on a.intEntityRoleId = b.intUserRoleID
		join tblEMEntity c
			on a.intEntityId = c.intEntityId
		join tblEMEntity d
			on a.intEntityContactId = d.intEntityId
		left join [tblEMEntityCredential] e
			on a.intEntityContactId = e.intEntityId
