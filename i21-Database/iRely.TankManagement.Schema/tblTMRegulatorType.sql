CREATE TABLE [dbo].[tblTMRegulatorType] (
    [intConcurrencyId]   INT           DEFAULT ((1)) NOT NULL,
    [intRegulatorTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [strRegulatorType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]         BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMRegulatorType] PRIMARY KEY CLUSTERED ([intRegulatorTypeId] ASC),
    CONSTRAINT [IX_tblTMRegulatorType] UNIQUE NONCLUSTERED ([strRegulatorType] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRegulatorType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRegulatorType',
    @level2type = N'COLUMN',
    @level2name = N'intRegulatorTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Regulator Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRegulatorType',
    @level2type = N'COLUMN',
    @level2name = N'strRegulatorType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicate if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMRegulatorType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'