CREATE TABLE [dbo].[tblICStorageMeasurementReadingConversion]
(
	[intStorageMeasurementReadingConversionId] INT NOT NULL IDENTITY, 
    [intStorageMeasurementReadingId] INT NOT NULL, 
    [intCommodityId] INT NULL, 
    [intItemId] INT NOT NULL, 
    [intStorageLocationId] INT NOT NULL, 
    [dblAirSpaceReading] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblCashPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intDiscountSchedule] INT NULL,
	[dblEffectiveDepth] NUMERIC(18, 6) NULL,
	[dblOnHand] NUMERIC(18, 6) NULL,
	[dblNewOnHand] NUMERIC(18, 6) NULL,
	[dblValue] NUMERIC(18, 6) NULL,
	[dblUnitPerFoot] NUMERIC(18, 6) NULL,
	[dblResidualUnit] NUMERIC(18, 6) NULL,
	[dblGainLoss] NUMERIC(18, 6) NULL,
	[dblVariance] NUMERIC(18, 6) NULL,
    [intSort] INT NULL, 
	[intCompanyId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)),
    [dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
    CONSTRAINT [PK_tblICStorageMeasurementReadingConversion] PRIMARY KEY ([intStorageMeasurementReadingConversionId]), 
    CONSTRAINT [FK_tblICStorageMeasurementReadingConversion_tblICStorageMeasurementReading] FOREIGN KEY ([intStorageMeasurementReadingId]) REFERENCES [tblICStorageMeasurementReading]([intStorageMeasurementReadingId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICStorageMeasurementReadingConversion_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblICStorageMeasurementReadingConversion_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICStorageMeasurementReadingConversion_tblICStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
    CONSTRAINT [AK_tblICStorageMeasurementReadingConversion] UNIQUE ([intStorageMeasurementReadingId], [intCommodityId], [intItemId], [intStorageLocationId]), 
    CONSTRAINT [FK_tblICStorageMeasurementReadingConversion_tblGRDiscountId] FOREIGN KEY ([intDiscountSchedule]) REFERENCES [tblGRDiscountId]([intDiscountId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intStorageMeasurementReadingConversionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Measurement Reading Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intStorageMeasurementReadingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Air Space Reading',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'dblAirSpaceReading'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cash Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'dblCashPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReadingConversion',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'