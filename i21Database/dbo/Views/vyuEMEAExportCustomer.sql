CREATE VIEW [dbo].[vyuEMEAExportCustomer]
	AS 
	
	
	select 
		intId 				= a.intEntityId,
		[Id]				= a.strEntityNo COLLATE Latin1_General_CI_AS,
		[Description]		= a.strName COLLATE Latin1_General_CI_AS,
		[GroupRequired]		= cast(0 as bit),
		[LocationRequired]	= cast(1 as bit),
		[CreditHold]		= cast(c.ysnCreditHold as bit),
		[Taxable]			= cast(c.ysnApplySalesTax as bit),
		[VFDDealer]			= cast(0 as bit),
		[VFDAcknowledged]	= cast(0 as bit),
		[OrganicType]		= cast(0 as int),	
	
		LastName			= ISNULL ( SUBSTRING((CASE WHEN CHARINDEX(' ', e.strName) > 0 THEN SUBSTRING(SUBSTRING(e.strName,1,30),CHARINDEX(' ',e.strName) + 1, LEN(e.strName))END), 1, 20) , '') COLLATE Latin1_General_CI_AS,	
		FirstName			= ISNULL ( SUBSTRING((CASE WHEN CHARINDEX(' ', e.strName) > 0 THEN SUBSTRING(SUBSTRING(e.strName,1,30), 0, CHARINDEX(' ',e.strName)) ELSE SUBSTRING(e.strName,1,30)END), 1, 20) , '') COLLATE Latin1_General_CI_AS,
		[Name]				= ISNULL ( e.strName, '') COLLATE Latin1_General_CI_AS,
	
		Address1			= ISNULL ( dbo.fnEMSplitWithGetByIdx(f.strAddress,char(10),1) , '') COLLATE Latin1_General_CI_AS,
		Address2			= ISNULL ( dbo.fnEMSplitWithGetByIdx(f.strAddress,char(10),2) , '') COLLATE Latin1_General_CI_AS,
		City				= ISNULL ( f.strCity, '') COLLATE Latin1_General_CI_AS,
		StateProv			= ISNULL ( f.strState, '') COLLATE Latin1_General_CI_AS,
		PostalCode			= ISNULL ( f.strZipCode, '') COLLATE Latin1_General_CI_AS,
		[Phone]				= ISNULL ( g.strPhone, '') COLLATE Latin1_General_CI_AS,
		[Mobile]			= ISNULL ( h.strPhone, '') COLLATE Latin1_General_CI_AS,
	
		Fax					= ISNULL ( j.strFax, '') COLLATE Latin1_General_CI_AS,
		Email				= ISNULL ( e.strEmail, '') COLLATE Latin1_General_CI_AS,
		Website				= ISNULL ( i.strWebsite, '') COLLATE Latin1_General_CI_AS,
		ModifiedDate		= coalesce(c.dtmDateModified,c.dtmDateCreated ),
		Comment				= ''

	from tblEMEntity a
	join tblEMEntityType b
		on a.intEntityId = b.intEntityId and b.strType = 'Customer'
	join tblARCustomer c 
		on a.intEntityId = c.intEntityId
	join tblEMEntityToContact d
		on a.intEntityId = d.intEntityId and d.ysnDefaultContact = 1
	join tblEMEntity e
		on d.intEntityContactId = e.intEntityId
	join tblEMEntityLocation f
		on a.intEntityId = f.intEntityId and f.ysnDefaultLocation = 1
	outer apply ( 
			select top 1 strPhone = isnull(strPhone, '') from tblEMEntityPhoneNumber where intEntityId = d.intEntityContactId
		) g
	outer apply ( 
			select top 1 strPhone = isnull(strPhone, '') from tblEMEntityMobileNumber where intEntityId = d.intEntityContactId
		) h
	outer apply ( 
			select top 1 isnull(aa.strValue, '') strWebsite from tblEMContactDetail aa
				join tblEMContactDetailType bb
					on aa.intContactDetailTypeId = bb.intContactDetailTypeId and strField = 'Website'
				where aa.intEntityId = d.intEntityContactId
	) i
	
	outer apply ( 
			select top 1 isnull(aa.strValue, '') strFax from tblEMContactDetail aa
				join tblEMContactDetailType bb
					on aa.intContactDetailTypeId = bb.intContactDetailTypeId and strField = 'Fax'
				where aa.intEntityId = d.intEntityContactId
	) j
	
