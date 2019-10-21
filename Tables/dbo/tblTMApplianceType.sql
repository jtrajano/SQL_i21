CREATE TABLE [dbo].[tblTMApplianceType] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intApplianceTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strApplianceType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]         BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMApplianceType] PRIMARY KEY CLUSTERED ([intApplianceTypeID] ASC),
    CONSTRAINT [UQ_tblTMApplianceType_strApplianceType] UNIQUE NONCLUSTERED ([strApplianceType] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Checking',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMApplianceType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMApplianceType',
    @level2type = N'COLUMN',
    @level2name = N'intApplianceTypeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Appliance Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMApplianceType',
    @level2type = N'COLUMN',
    @level2name = N'strApplianceType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMApplianceType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'