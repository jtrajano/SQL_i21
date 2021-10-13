CREATE TABLE [dbo].[tblApiSchemaVendor]
(
	--Required Fields
	[guiApiUniqueId] 			UNIQUEIDENTIFIER NOT NULL,
	[intRowNumber] 				INT NULL,

	--Import Fields
	[intKey] 					INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	[intId] 					INT NULL,
	
	--Entity Fields
	[strEntityNo]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,			--ENTITY NO
	[strName]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,			--ENTITY NAME
	[strWebsite]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,				--ENTITY WEBSITE
	[strContactNumber]			NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,			--ENTITY CONTACT NUMBER
	[strMobile]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,				--ENTITY MOBILE NUMBER
	[strFax]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,				--ENTITY FAX
	[strEmail]					NVARCHAR (75) COLLATE Latin1_General_CI_AS  NULL DEFAULT(''),	--ENTITY EMAIL
	[strTimezone]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--ENTITY TIME ZONE

	--Entity Contact Fields
	[strContactName]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,			--CONTACT NAME

	--Entity Location Fields
	[strLocationName]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,			--LOCATION NAME
	[strAddress]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--ADDRESS
	[strCity]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--CITY
	[strState]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--STATE
	[strZipCode]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--ZIP CODE
	[strCountry]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--COUNTRY
	[strPricingLevel]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,				--PRICING LEVEL

	--Entity Type Fields
	[strType]          			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,				--ENTITY TYPE

	-- LOOKING FOR WAREHOUSE FIELD

	--Vendor Fields
	[strVendorId]               NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,			--VENDOR NO
	[strExpenseAccountId]      	NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,				--VENDOR EXPENSE ACCOUNT
	[strVendorType] 			NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 				--VENDOR TYPE
	[strTaxNumber] 				NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,					--VENDOR TAX NUMBER
	[strTerm]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL			--VENDOR TERM

	-- --User Fields
	-- [strUserName]						NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
	-- [strPassword]						NVARCHAR(255)  COLLATE Latin1_General_CI_AS NOT NULL,
	-- [strUserRole]						NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NOT NULL,
	-- [strUserPolicy]						NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NOT NULL
)