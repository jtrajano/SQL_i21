CREATE TABLE [dbo].[tblApiSchemaVendorLocation]
(
	--Required Fields
	[guiApiUniqueId] 			UNIQUEIDENTIFIER NOT NULL,
	[intRowNumber] 				INT NULL,

	--Import Fields
	[intKey] 					INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	[intId] 					INT NULL,

	--Vendor Location Fields
	[strEntityNo]               NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,					--ENTITY NO
	[strLocationName]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,					--LOCATION NAME
	[strAddress]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--ADDRESS
	[strCity]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--CITY
	[strCountry]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--COUNTRY
	[strCounty]		            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--COUNTY
	[strState]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--STATE/PROVINCE
    [strZipCode]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--ZIP/POSTAL
    [strPhone]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--PHONE
    [strFax]                    NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--FAX
	[strPricingLevel]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL, 						--PRICING LEVEL * (01-20)
    [strNotes]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--NOTES
	[strOregonFacilityNumber]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--STATE FACILITY NO
	[strShipVia]         		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,						--SHIP VIA * (tblSMShipVia)
	[strTerm]					NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL, 						--TERMS * (tblSMTerms)
	[strWarehouseName] 			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 						--WAREHOUSE * (tblSMCompanyLocation)
	[strFreightTerm]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 					--FREIGHT TERMS (tblSMFreightTerms)
	[strTaxCode]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 						--TAX CODE * (tblSMTaxCode)
	[strTaxGroup] 				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,							--TAX GROUP * (tblSMTaxGroup)
	[strTaxClass] 				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 						--TAX CLASS * (tblSMTaxClass)
	[ysnActive]				    BIT NULL DEFAULT(1),													--ACTIVE
	[dblLongitude]              NUMERIC (18, 6) DEFAULT ((0)) NULL,										--LONGITUDE
    [dblLatitude]               NUMERIC (18, 6) DEFAULT ((0)) NULL,										--LATITUDE
    [strTimezone]               NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--TIME ZONE
    [strCheckPayeeName]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,					--PRINTED NAME
	[strCurrency]         		NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,						--CURRENCY (tblSMCurrency)
	[strVendorLink]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,						--VENDOR LINK (tblAPVendor)
	[strLocationDescription]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--DESCRIPTION
    [strLocationType]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL DEFAULT('Location'), 	--LOCATION TYPE
	[strFarmFieldNumber]        NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,						--FARM FIELD NUMBER
    [strFarmFieldDescription]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--FARM FIELD DESCRIPTION
    [strFarmFSANumber]			NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--FARM FSA NUMBER
    [strFarmSplitNumber]		NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,    					--FARM SPLIT NUMBER
    [strFarmSplitType]			NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,						--FARM SPLIT TYPE
    [dblFarmAcres]				NUMERIC(18, 6) DEFAULT ((0)) NULL,										--FARM ACRES
	[ysnPrint1099]              BIT NULL,																--PRINT 1099
    [str1099Name]               NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,						--1099 NAME
    [str1099Form]               NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,						--1099 FORM * (DATA.forms1099)
    [str1099Type]               NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,						--1099 TYPE * (tblAP1099DIVCategory)
    [strFederalTaxId]           NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL,						--FEDERAL TAX ID
    [dtmW9Signed]               DATETIME NULL															--W9 SIGNED
)