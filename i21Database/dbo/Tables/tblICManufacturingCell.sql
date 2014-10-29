CREATE TABLE [dbo].[tblICManufacturingCell]
(
	[intManufacturingCellId] INT NOT NULL IDENTITY, 
    [strCellName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intLocationId] INT NULL, 
    [strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblStdCapacity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intStdUnitMeasureId] INT NULL, 
    [intStdCapacityRateId] INT NULL, 
    [dblStdLineEfficiency] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnIncludeSchedule] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICManufacturingCell] PRIMARY KEY ([intManufacturingCellId]), 
    CONSTRAINT [AK_tblICManufacturingCell_strCellName] UNIQUE ([strCellName]), 
    CONSTRAINT [FK_tblICManufacturingCell_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICManufacturingCell_StandardUnitMeasure] FOREIGN KEY ([intStdUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblICManufacturingCell_CapacityUnitMeasure] FOREIGN KEY ([intStdCapacityRateId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intManufacturingCellId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cell Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'strCellName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'dblStdCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Capacity Unit Measure',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intStdUnitMeasureId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Capacity Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intStdCapacityRateId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Line Efficiency Rate (%)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'dblStdLineEfficiency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Include in Scheduling',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'ysnIncludeSchedule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturingCell',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'