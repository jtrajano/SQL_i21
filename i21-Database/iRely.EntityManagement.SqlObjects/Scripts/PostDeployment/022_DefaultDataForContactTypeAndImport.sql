PRINT '*** Start Defaults for Contact Type And Import***'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetailType')	
	AND EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMContactDetail')	
	AND NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Defaults for Contact Type And Import')

BEGIN
	/* Creating Default Values for Contact Detail Type */
	PRINT '*** START DEFAULT VALUES FOR ENTITY CONTACT DETAIL TYPE'

	SET IDENTITY_INSERT tblEMContactDetailType ON 
	INSERT INTO tblEMContactDetailType ( 
			intContactDetailTypeId,		strField,		strType,				strMasking,		ysnDefault
	)
	SELECT 	1,							'Work',			'Phone',				'+',			1
	UNION
	SELECT	2,							'Home',			'Phone',				'+',			1
	UNION
	SELECT	3,							'Fax',			'Phone',				'+',			1
	UNION
	SELECT	4,							'Alt Email',	'Email',				'+',			1
	UNION
	SELECT	5,							'Website',		'URL',					'+',			1
	UNION
	SELECT	6,							'Blog',			'URL',					'+',			1
	UNION
	SELECT	7,							'Facebook',		'URL',					'+',			1
	UNION
	SELECT	8,							'Twitter',		'URL',					'+',			1
	UNION
	SELECT	9,							'LinkedIn',		'URL',					'+',			1
	UNION
	SELECT	10,							'Youtube',		'URL',					'+',			1
	


	SET IDENTITY_INSERT tblEMContactDetailType OFF

	PRINT '*** END DEFAULT VALUES FOR ENTITY CONTACT DETAIL TYPE'
	
	/* IMPORTING VALUES FROM ENTITY */	


	/* IMPORTING ALT PHONE */
	PRINT 'ALT PHONE'

	insert into tblEMContactDetail
			(	intEntityId,		intContactDetailTypeId,			strValue )
	SELECT		a.intEntityId,		b.intContactDetailTypeId,		a.strPhone2  FROM tblEMEntity a
		JOIN tblEMContactDetailType b 
			on  b.strField = 'Work'
		where a.strPhone2 is not null and a.strPhone2<> ''
		and a.intEntityId not in ( select intEntityId from tblEMContactDetail e_type where e_type.intContactDetailTypeId = 2)

	/* IMPORTING ALT EMAIL */
	PRINT 'ALT EMAIL'

	insert into tblEMContactDetail
			(	intEntityId,		intContactDetailTypeId,			strValue )
	SELECT		a.intEntityId,		b.intContactDetailTypeId,		a.strEmail2  FROM tblEMEntity a
		JOIN tblEMContactDetailType b 
			on  b.strField = 'Alt Email'
		where a.strEmail2 is not null and a.strEmail2<> ''
		and a.intEntityId not in ( select intEntityId from tblEMContactDetail e_type where e_type.intContactDetailTypeId = 3)

	/* IMPORTING FAX */
	PRINT 'FAX'

	insert into tblEMContactDetail
			(	intEntityId,		intContactDetailTypeId,			strValue )
	SELECT		a.intEntityId,		b.intContactDetailTypeId,		a.strFax  FROM tblEMEntity a
		JOIN tblEMContactDetailType b 
			on  b.strField = 'Fax'
		where a.strFax is not null and a.strFax<> ''
		and a.intEntityId not in ( select intEntityId from tblEMContactDetail e_type where e_type.intContactDetailTypeId = 4)

	/* IMPORTING WEBSITE */
	PRINT 'WEBSITE'

	insert into tblEMContactDetail
			(	intEntityId,		intContactDetailTypeId,			strValue )
	SELECT		a.intEntityId,		b.intContactDetailTypeId,		d.strWebsite  FROM tblEMEntity a
		JOIN tblEMContactDetailType b 
			on  b.strField = 'Website'
		JOIN [tblEMEntityToContact] c 
			on a.intEntityId = c.intEntityContactId
		JOIN tblEMEntity d
			on d.intEntityId = c.intEntityId
		where d.strWebsite is not null and d.strWebsite<> ''
		and a.intEntityId not in ( select intEntityId from tblEMContactDetail e_type where e_type.intContactDetailTypeId = 5)
	
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Defaults for Contact Type And Import', 1)
	
END
PRINT '*** End Defaults for Contact Type And Import***'




if not exists(select top 1 1 from tblEMContactDetailType where strField = 'Skype' and strType = 'Email')
begin
	INSERT INTO tblEMContactDetailType ( 
			strField,		strType,				strMasking,		ysnDefault
	)
	SELECT 	'Skype',		'Email',				'+',			1
end