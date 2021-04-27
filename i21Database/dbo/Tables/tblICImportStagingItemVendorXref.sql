CREATE TABLE [dbo].[tblICImportStagingItemVendorXref]
(
	[intImportStagingItemVendorXrefId] INT NOT NULL IDENTITY,
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strVendor] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strVendorProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[dblConversionFactor] NUMERIC(38, 20) NOT NULL DEFAULT ((0)),
	[strUnitOfMeasure] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intSort] INT NULL,
	[strImportIdentifier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblICImportStagingItemVendorXref] PRIMARY KEY ([intImportStagingItemVendorXrefId])
)