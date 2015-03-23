CREATE TABLE [dbo].[tblTMDeviceType] (
    [intConcurrencyId] INT           DEFAULT 1 NOT NULL,
    [intDeviceTypeId]  INT           IDENTITY (1, 1) NOT NULL,
    [strDeviceType]    NVARCHAR (70) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMDeviceType] PRIMARY KEY CLUSTERED ([intDeviceTypeId] ASC),
    CONSTRAINT [UQ_tblTMDeviceType_strDeviceType] UNIQUE NONCLUSTERED ([strDeviceType] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeviceType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeviceType',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeviceType',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMDeviceType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'