CREATE TABLE [dbo].[tblICCommodityAccount]
(
	[intCommodityAccountId] INT NOT NULL IDENTITY, 
    [intCommodityId] INT NOT NULL, 
    [strAccountDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId] INT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCommodityAccount] PRIMARY KEY ([intCommodityAccountId]), 
    CONSTRAINT [FK_tblICCommodityAccount_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblICCommodityAccount_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
    CONSTRAINT [AK_tblICCommodityAccount] UNIQUE ([strAccountDescription], [intCommodityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'strAccountDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
