CREATE VIEW [dbo].[vyuEMEAExportCustomer]
AS 
SELECT [intId] 				= a.intEntityId
	 , [Id]					= LTRIM(RTRIM(a.strEntityNo)) COLLATE Latin1_General_CI_AS
	 , [Description]		= LTRIM(RTRIM(a.strName)) COLLATE Latin1_General_CI_AS
	 , [GroupRequired]		= CAST(0 AS BIT)
	 , [LocationRequired]	= CAST(1 AS BIT)
	 , [CreditHold]			= CAST(c.ysnCreditHold AS BIT)
	 , [Taxable]			= CAST(c.ysnApplySalesTax AS BIT)
	 , [VFDDealer]			= CAST(0 AS BIT)
	 , [VFDAcknowledged]	= CAST(0 AS BIT)
	 , [OrganicType]		= CAST(0 AS INT)
	 , [LastName]			= ISNULL(SUBSTRING((CASE WHEN CHARINDEX(' ', e.strName) > 0 THEN SUBSTRING(SUBSTRING(e.strName,1,30),CHARINDEX(' ',e.strName) + 1, LEN(e.strName))END), 1, 20) , '') COLLATE Latin1_General_CI_AS
	 , [FirstName]			= ISNULL(SUBSTRING((CASE WHEN CHARINDEX(' ', e.strName) > 0 THEN SUBSTRING(SUBSTRING(e.strName,1,30), 0, CHARINDEX(' ',e.strName)) ELSE SUBSTRING(e.strName,1,30)END), 1, 20) , '') COLLATE Latin1_General_CI_AS
	 , [Name]				= ISNULL(e.strName, '') COLLATE Latin1_General_CI_AS
	 , [Address1]			= ISNULL(dbo.fnEMSplitWithGetByIdx(f.strAddress,char(10),1) , '') COLLATE Latin1_General_CI_AS
	 , [Address2]			= ISNULL(dbo.fnEMSplitWithGetByIdx(f.strAddress,char(10),2) , '') COLLATE Latin1_General_CI_AS
	 , [City]				= ISNULL(f.strCity, '') COLLATE Latin1_General_CI_AS
	 , [StateProv]			= ISNULL(f.strState, '') COLLATE Latin1_General_CI_AS
	 , [PostalCode]			= ISNULL(f.strZipCode, '') COLLATE Latin1_General_CI_AS
	 , [Phone]				= ISNULL(PHONE.strPhone, '') COLLATE Latin1_General_CI_AS
	 , [Mobile]				= ISNULL(MOBILE.strPhone, '') COLLATE Latin1_General_CI_AS
	 , [Fax]				= ISNULL(FAX.strFax, '') COLLATE Latin1_General_CI_AS
	 , [Email]				= ISNULL(e.strEmail, '') COLLATE Latin1_General_CI_AS
	 , [Website]			= ISNULL(WEBSITE.strWebsite, '') COLLATE Latin1_General_CI_AS
	 , [ModifiedDate]		= COALESCE(c.dtmDateModified, c.dtmDateCreated)
	 , [Comment]			= ''
FROM tblEMEntity a
INNER JOIN tblEMEntityType b ON a.intEntityId = b.intEntityId and b.strType = 'Customer'
INNER JOIN tblARCustomer c ON a.intEntityId = c.intEntityId
INNER JOIN tblEMEntityToContact d ON a.intEntityId = d.intEntityId and d.ysnDefaultContact = 1
INNER JOIN tblEMEntity e ON d.intEntityContactId = e.intEntityId
INNER JOIN tblEMEntityLocation f ON a.intEntityId = f.intEntityId and f.ysnDefaultLocation = 1
OUTER APPLY ( 
	SELECT TOP 1 strPhone = ISNULL(strPhone, '') 
	FROM tblEMEntityPhoneNumber 
	WHERE intEntityId = d.intEntityContactId
) PHONE
OUTER APPLY ( 
	SELECT TOP 1 strPhone = ISNULL(strPhone, '') 
	FROM tblEMEntityMobileNumber 
	WHERE intEntityId = d.intEntityContactId
) MOBILE
OUTER APPLY ( 
	SELECT TOP 1 strWebsite = ISNULL(aa.strValue, '') 
	FROM tblEMContactDetail aa
	INNER JOIN tblEMContactDetailType bb ON aa.intContactDetailTypeId = bb.intContactDetailTypeId AND strField = 'Website'
	WHERE aa.intEntityId = d.intEntityContactId
) WEBSITE
OUTER APPLY ( 
	SELECT TOP 1 strFax = ISNULL(aa.strValue, '') 
	FROM tblEMContactDetail aa
	INNER JOIN tblEMContactDetailType bb ON aa.intContactDetailTypeId = bb.intContactDetailTypeId AND strField = 'Fax'
	WHERE aa.intEntityId = d.intEntityContactId
) FAX