CREATE TABLE [dbo].[tblApiSchemaVendorPricing]
(
	--Required Fields
	[guiApiUniqueId] 			UNIQUEIDENTIFIER NOT NULL,
	[intRowNumber] 				INT NULL,

	--Import Fields
	[intKey] 					INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	[intId] 					INT NULL,

	--Vendor Pricing Fields
	[strVendorId]               NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,			--VENDOR NO
	[strLocationName]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,			--LOCATION NAME
	[strItemNo]                 NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,			--ITEM NO
	[strDescription]            NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,				--ITEM DESCRIPTION
	[strUnitMeasure] 			NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 			--ITEM UOM
	[dblPrice]					DECIMAL(18, 6) NOT NULL, 										--PRICE
	[strCurrency]         		NVARCHAR (40) COLLATE Latin1_General_CI_AS NOT NULL,			--CURRENCY
	[dtmBeginDate]				DATETIME NOT NULL,												--BEGIN DATE
	[dtmEndDate]				DATETIME NOT NULL												--END DATE
)