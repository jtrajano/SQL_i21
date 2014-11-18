CREATE TABLE [dbo].[tblICStorageLocationMeasurement]
(
	[intStorageLocationMeasurementId] INT NOT NULL IDENTITY, 
    [intStorageLocationId] INT NOT NULL, 
    [intMeasurementId] INT NULL, 
    [intReadingPointId] INT NULL, 
    [ysnActive] BIT NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICStorageLocationMeasurement] PRIMARY KEY ([intStorageLocationMeasurementId]), 
    CONSTRAINT [FK_tblICStorageLocationMeasurement_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationMeasurementId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intStorageLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Measurement Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intMeasurementId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reading Point Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intReadingPointId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageLocationMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'