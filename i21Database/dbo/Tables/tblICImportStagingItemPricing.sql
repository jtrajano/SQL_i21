CREATE TABLE [dbo].[tblICImportStagingItemPricing]
(
    [intImportStagingItemPricingId] INT IDENTITY(1, 1) NOT NULL,
    [strImportIdentifier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblLastCost] NUMERIC(38, 20) NULL,
    [dblStandardCost] NUMERIC(38, 20) NULL,
    [dblAverageCost] NUMERIC(38, 20) NULL,
    [strPricingMethod] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblAmountPercent] NUMERIC(38, 20) NULL,
    [dblRetailPrice] NUMERIC(38, 20) NULL,
    [dblMSRP] NUMERIC(38, 20) NULL,
    [dblDefaultGrossPrice] NUMERIC(38, 20) NULL,
    [dtmEffectiveCostDate] DATETIME NULL,
    [dtmEffectiveRetailDate] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [dtmDateCreated] DATETIME NULL,
    [intModifiedByUserId] INT NULL,
    [intCreatedByUserId] INT NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblICImportStagingItemPricing] PRIMARY KEY ([intImportStagingItemPricingId] ASC)
)