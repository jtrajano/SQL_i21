CREATE TABLE [dbo].[tblICStatus]
(
	[intStatusId] INT NOT NULL IDENTITY, 
    [strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICStatus] PRIMARY KEY ([intStatusId]), 
    CONSTRAINT [AK_tblICStatus_strStatus] UNIQUE ([strStatus]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStatus',
    @level2type = N'COLUMN',
    @level2name = N'intStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Status',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStatus',
    @level2type = N'COLUMN',
    @level2name = N'strStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStatus',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICStatus',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'