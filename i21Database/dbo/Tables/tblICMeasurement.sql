CREATE TABLE [dbo].[tblICMeasurement]
(
	[intMeasurementId] INT NOT NULL IDENTITY, 
    [strMeasurementName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strMeasurementType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICMeasurement] PRIMARY KEY ([intMeasurementId]), 
    CONSTRAINT [AK_tblICMeasurement_strMeasurementName] UNIQUE ([strMeasurementName]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intMeasurementId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Measurement Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'strMeasurementName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Measurement Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMeasurement',
    @level2type = N'COLUMN',
    @level2name = 'strMeasurementType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICMeasurement',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'