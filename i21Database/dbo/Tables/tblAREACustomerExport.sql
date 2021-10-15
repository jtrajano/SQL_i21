CREATE TABLE [dbo].[tblAREACustomerExport]
(
	[intEntityId] INT NOT NULL PRIMARY KEY,
	--Id
	[strEntityNo]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,	
	--Description
    [strName]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strAccountType]		NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	--GroupRequired
	[ysnGroupRequired]		BIT NOT NULL DEFAULT(1),
	--LocationRequired
	[ysnLocationRequired]	BIT NOT NULL DEFAULT(1),
	--CreditHold
	[ysnCreditHold]			BIT NOT NULL DEFAULT(1),
	--Taxable
	[ysnTaxable]			BIT NOT NULL DEFAULT(1),
	--VFDDealer
	[ysnVFDDealer]			BIT NOT NULL DEFAULT(1),
	--VFDAcknowledged
	[ysnVFDAcknowledged]	BIT NOT NULL DEFAULT(1),
	--OrganicType
	[intOrganicType]		INT NOT NULL DEFAULT(1),
	
	--LastName
	strLastName				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
	--FirstName
	strFirstName			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
	--Address1
	strAddress1				NVARCHAR(1000) COLLATE Latin1_General_CI_AS NOT NULL,
	--Address2
	strAddress2				NVARCHAR(1000) COLLATE Latin1_General_CI_AS NOT NULL,	
	--City
	strCity					NVARCHAR(1000) COLLATE Latin1_General_CI_AS NOT NULL,	
	strCountry				NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,	
	--StateProv
	strStateProv			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NOT NULL,	
	--PostalCode
	strPostalCode			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NOT NULL,	
	--Phone
	strPhone				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
	--Mobile
	strMobile				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
	--Fax
	strFax					NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
	--Email
	strEmail				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,	
	--Website
	strWebsite				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	--Comment
	strComment				NVARCHAR(0100) COLLATE Latin1_General_CI_AS NOT NULL,
	
	strLicenseApplicator    NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	dtmLicenseExpirationDate DATETIME NULL,
	dblARBalance NUMERIC(18, 6) NULL,
	dblCreditLimit NUMERIC(18, 6) NULL,
	dblShipToLatitude NUMERIC(18, 6) NULL,
	dblShipToLongitude NUMERIC(18, 6) NULL,
	dtmDateCreated DATETIME2 NULL,
	dtmDateModified DATETIME2 NULL,
	dtmDateLastUpdated AS COALESCE(dtmDateModified, dtmDateCreated)
)
