CREATE VIEW [dbo].[vyuApiCustomer]
AS 
SELECT [EntityId]			= e.intEntityId
	 , [Id]					= LTRIM(RTRIM(e.strCustomerNumber)) COLLATE Latin1_General_CI_AS
	 , [CustomerNumber]		= LTRIM(RTRIM(e.strCustomerNumber)) COLLATE Latin1_General_CI_AS
	 , [Description]		= LTRIM(RTRIM(e.strName)) COLLATE Latin1_General_CI_AS
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
	 , [Address1]			= ISNULL(dbo.fnEMSplitWithGetByIdx(e.strAddress,char(10),1) , '') COLLATE Latin1_General_CI_AS
	 , [Address2]			= ISNULL(dbo.fnEMSplitWithGetByIdx(e.strAddress,char(10),2) , '') COLLATE Latin1_General_CI_AS
	 , [City]				= ISNULL(e.strCity, '') COLLATE Latin1_General_CI_AS
	 , [StateProv]			= ISNULL(e.strState, '') COLLATE Latin1_General_CI_AS
	 , [PostalCode]			= ISNULL(e.strZipCode, '') COLLATE Latin1_General_CI_AS
	 , [Phone]				= ISNULL(PHONE.strPhone, '') COLLATE Latin1_General_CI_AS
	 , [Mobile]				= ISNULL(MOBILE.strPhone, '') COLLATE Latin1_General_CI_AS
	 , [Fax]				= ISNULL(FAX.strFax, '') COLLATE Latin1_General_CI_AS
	 , [Email]				= ISNULL(e.strEmail, '') COLLATE Latin1_General_CI_AS
	 , [Website]			= ISNULL(WEBSITE.strWebsite, '') COLLATE Latin1_General_CI_AS
	 , [Comment]			= ''
	 , [LicenseApplicator] 	= g.strLicenseNo 
	 , [LicenseExpirationDate] = g.dtmExpirationDate
	 , [Country]			= e.strCountry
	 , [ARBalance]			= c.dblARBalance
	 , [CreditLimit]		= c.dblCreditLimit
	 , [ShipToLatitude]		= e.dblShipToLatitude
	 , [ShipToLongitude]	= e.dblShipToLongitude
	 , [DateModified]		= c.dtmDateModified
	 , [DateCreated]		= c.dtmDateCreated
	 , [AccountType]		= e.strAccountType
	 , [FreightTermId]		= e.intFreightTermId
	 --, [FreightTerm]		= e.strFreightTerm
	 , [TermId]				= e.intTermsId
	 --, [Term]				= e.strTerm
	 --, [Currency]			= e.strCurrency
	 , [CurrencyId]			= e.intCurrencyId
	 , [ShipViaId]			= e.intShipViaId
	 --, [ShipVia]			= e.strShipViaName
	 , [BillToLocationId]	= e.intBillToId
	 --, [BillToLocation]		= e.strBillToLocationName
	 , [ShipToLocationId]	= e.intShipToId
	 --, [ShipToLocation]		= e.strShipToLocationName
	 , [IsActive]			= e.ysnActive
	 , [IsGroupRequired]	= CAST(0 AS BIT)
	 , [IsLocationRequired]	= CAST(1 AS BIT)
	 , [IsCreditHold]		= CAST(c.ysnCreditHold AS BIT)
	 , [IsTaxable]			= CAST(c.ysnApplySalesTax AS BIT)
	 , [IsVFDDealer]		= CAST(0 AS BIT)
	 , [IsVFDAcknowledged]	= CAST(0 AS BIT)
	 , [DateLastUpdated]	= COALESCE(c.dtmDateModified, c.dtmDateCreated)
     , [SalespersonId]      = e.intSalespersonId
     , [ContactId]          = e.intEntityContactId
FROM vyuEMEntityCustomerSearch e
LEFT JOIN tblARCustomer c ON c.intEntityId = e.intEntityId
LEFT JOIN tblARCustomerApplicatorLicense g ON g.intEntityCustomerId = e.intEntityId
LEFT JOIN tblEMEntityToContact d ON e.intEntityId = d.intEntityId and d.ysnDefaultContact = 1
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
WHERE e.intWarehouseId IN (-99,-99,1,2,3,4,5,6,7,8,9,10,11,12,13,36,41,42,45,46,51,52,53,56,57,58,59,60,61,63,66)