CREATE TABLE [dbo].[tblICImportStagingItemPriceWithEffectiveDate]
(
    [intImportStagingItemPriceWithEffectiveDateId] INT IDENTITY(1, 1) NOT NULL,
    [strImportIdentifier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strUnitMeasure] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblPrice] NUMERIC(38, 20) NOT NULL,
	[dtmEffectiveDate] DATETIME NOT NULL,
    [dtmDateModified] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL,
    [intModifiedByUserId] INT NULL,
    [intCreatedByUserId] INT NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblICImportStagingItemPriceWithEffectiveDate] PRIMARY KEY ([intImportStagingItemPriceWithEffectiveDateId] ASC)
)