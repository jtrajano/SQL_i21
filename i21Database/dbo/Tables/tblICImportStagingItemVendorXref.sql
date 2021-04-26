CREATE TABLE [dbo].[tblICImportStagingItemVendorXref]
(
	[intImportStagingItemVendorXrefId] INT NOT NULL IDENTITY , 
	[strImportIdentifier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NOT NULL, 
	[intItemLocationId] INT NULL, 
	[intVendorId] INT NOT NULL, 
	[intVendorSetupId] INT NULL,
	[strVendorProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[dblConversionFactor] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
	[intItemUnitMeasureId] INT NULL, 
	[intSort] INT NULL, 
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	[intDataSourceId] TINYINT NULL,
	CONSTRAINT [PK_tblICImportStagingItemVendorXref] PRIMARY KEY ([intImportStagingItemVendorXrefId])
)