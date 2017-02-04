	CREATE TABLE [dbo].[tblLGLoadLSPStg]
	(
		[intLoadStgId] INT IDENTITY(1,1) PRIMARY KEY,
		[intLoadId] INT,
		[strTransactionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strLoadNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strShipmentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strPartnerQualifier] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- PARTNER_Q 
		[strLanguage] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- LANGUAGE  
		[strVendorName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Vendor Name
		[strVendorAddress] NVARCHAR(1000) COLLATE Latin1_General_CI_AS, -- Vendor Name
		[strVendorPostalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Vendor Name
		[strVendorCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Vendor Name
		[strVendorTelePhoneNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Vendor Name
		[strVendorTeleFaxNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Vendor Name
		[strVendorCountry] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Vendor Name

		[strOriginName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Origin Name
		[strOriginAddress] NVARCHAR(1000) COLLATE Latin1_General_CI_AS, -- OriginName
		[strOriginPostalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Origin Name
		[strOriginCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Origin Name
		[strOriginTelePhoneNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Origin Name
		[strOriginTeleFaxNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Origin Name
		[strOriginCountry] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- OriginName
		[strOriginRegion] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Origin Name

		[strDestinationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationAddress] NVARCHAR(1000) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationPostalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationTelePhoneNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationTeleFaxNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationCountry] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name
		[strDestinationRegion] NVARCHAR(100) COLLATE Latin1_General_CI_AS, -- Destination Name

		[strContractBasis] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strContractBasisDesc] NVARCHAR(500) COLLATE Latin1_General_CI_AS, 
		[strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
		[strShippingLine] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
		[strShippingLineAccountNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
		[strExternalShipmentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
		[strDateQualifier] NVARCHAR(10) COLLATE Latin1_General_CI_AS,
		[dtmScheduledDate] DATETIME, 
		[dtmETAPOD] DATETIME, 
		[dtmETAPOL] DATETIME, 
		[dtmBLDate] DATETIME, 
		[strRowState] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[strFeedStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
		[dtmFeedCreated] DATETIME,
		[strMessage] NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	)