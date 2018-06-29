CREATE TABLE [dbo].[tblSMEULA]
(
	[intEULAId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strVersionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)

GO

CREATE INDEX [IX_tblSMEULA_strVersionNumber] ON [dbo].[tblSMEULA] ([strVersionNumber])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMEULA',
    @level2type = N'COLUMN',
    @level2name = N'intEULAId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Version Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMEULA',
    @level2type = N'COLUMN',
    @level2name = N'strVersionNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EULA text',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMEULA',
    @level2type = N'COLUMN',
    @level2name = N'strText'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMEULA',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'