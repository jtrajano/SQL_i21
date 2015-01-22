CREATE TABLE [dbo].[tblSCTruckDriverReference]
(
	[intTruckDriverReferenceId] INT NOT NULL  IDENTITY, 
    [intCustomerId] INT NULL, 
    [strRecordType] NVARCHAR COLLATE Latin1_General_CI_AS NULL, 
    [strData] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSCTruckDriverReference_intTruckDriverReferenceId] PRIMARY KEY ([intTruckDriverReferenceId]), 
    CONSTRAINT [FK_tblSCTruckDriverReference_tblARCustomer_intCustomerId] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intCustomerId]), 
    CONSTRAINT [AK_tblSCTruckDriverReference_intCustomerId_strRecordType_strData] UNIQUE ([intCustomerId], [strRecordType], [strData])
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
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTruckDriverReference',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
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