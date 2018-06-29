CREATE TABLE [dbo].[tblICStorageMeasurementReading]
(
	[intStorageMeasurementReadingId] INT NOT NULL IDENTITY, 
    [intLocationId] INT NOT NULL, 
    [dtmDate] DATETIME NOT NULL DEFAULT (GETDATE()), 
    [strReadingNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSort] INT NULL, 
	[intCompanyId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)),
    [dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
    CONSTRAINT [PK_tblICStorageMeasurementReading] PRIMARY KEY ([intStorageMeasurementReadingId]), 
    CONSTRAINT [FK_tblICStorageMeasurementReading_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReading',
    @level2type = N'COLUMN',
    @level2name = N'intStorageMeasurementReadingId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReading',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReading',
    @level2type = N'COLUMN',
    @level2name = N'dtmDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reading Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReading',
    @level2type = N'COLUMN',
    @level2name = N'strReadingNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReading',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStorageMeasurementReading',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'