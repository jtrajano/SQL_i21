CREATE TABLE [dbo].[tblSMScreenStage] (
    [intScreenStageId]      INT            IDENTITY (1, 1) NOT NULL,
    [strScreenId]      NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strScreenName]    NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strNamespace]     NVARCHAR (150) COLLATE Latin1_General_CI_AS NOT NULL,
    [strModule]        NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strTableName]     NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strChange]		   NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL,

    CONSTRAINT [PK_tblSMScreenStage] PRIMARY KEY CLUSTERED ([intScreenStageId] ASC)
);



GO

CREATE INDEX [IX_tblSMScreenStage_strScreenName] ON [dbo].[tblSMScreenStage] ([strScreenName])

GO

CREATE INDEX [IX_tblSMScreenStage_strModule] ON [dbo].[tblSMScreenStage] ([strModule])

GO

CREATE INDEX [IX_tblSMScreenStage_strScreenId] ON [dbo].[tblSMScreenStage] ([strScreenId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',

    @level2name = N'intScreenStageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',
    @level2name = N'strScreenId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',
    @level2name = N'strScreenName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Namespace of the Screen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',
    @level2name = N'strNamespace'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Module Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',
    @level2name = N'strModule'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Table Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',
    @level2name = N'strTableName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMScreenStage',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'