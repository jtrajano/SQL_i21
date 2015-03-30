CREATE TABLE [dbo].[tblSMControlStage]
(
	[intControStagelId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intScreenStageId] INT NULL, 
    [strControlId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strControlName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strContainer] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strControlType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMControlStage_tblSMScreenStage] FOREIGN KEY ([intScreenStageId]) REFERENCES [tblSMScreenStage]([intScreenStageId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMControlStage_intScreenId] ON [dbo].[tblSMControlStage] ([intScreenStageId])

GO

CREATE INDEX [IX_tblSMControlStage_strControlId] ON [dbo].[tblSMControlStage] ([strControlId])

GO

CREATE INDEX [IX_tblSMControlStage_strControlName] ON [dbo].[tblSMControlStage] ([strControlName])

GO

CREATE INDEX [IX_tblSMControlStage_strControlType] ON [dbo].[tblSMControlStage] ([strControlType])

GO

CREATE INDEX [IX_tblSMControlStage_strContainer] ON [dbo].[tblSMControlStage] ([strContainer])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'intControStagelId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Id from Screens table',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'intScreenStageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id of the Control',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'strControlId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Name of the Control',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'strControlName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Container where the Control belongs',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'strContainer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Control Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'strControlType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMControlStage',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'