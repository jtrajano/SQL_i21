CREATE TABLE [dbo].[tblSCTruckDriverReference]
(
	[intTruckDriverReferenceId] INT NOT NULL  IDENTITY, 
    [intEntityId] INT NULL, 
    [strRecordType] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [strData] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSCTruckDriverReference_intTruckDriverReferenceId] PRIMARY KEY ([intTruckDriverReferenceId]), 
    CONSTRAINT [FK_tblSCTruckDriverReference_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]), 
    CONSTRAINT [AK_tblSCTruckDriverReference_intEntityId_strRecordType_strData] UNIQUE ([intEntityId], [strRecordType], [strData])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTruckDriverReference',
    @level2type = N'COLUMN',
    @level2name = N'intTruckDriverReferenceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTruckDriverReference',
    @level2type = N'COLUMN',
    @level2name = 'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Record Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTruckDriverReference',
    @level2type = N'COLUMN',
    @level2name = N'strRecordType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTruckDriverReference',
    @level2type = N'COLUMN',
    @level2name = N'strData'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTruckDriverReference',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'