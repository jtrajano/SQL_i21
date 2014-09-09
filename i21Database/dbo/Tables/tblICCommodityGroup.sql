CREATE TABLE [dbo].[tblICCommodityGroup]
(
	[intCommodityGroupId] INT NOT NULL IDENTITY , 
    [intCommodityId] INT NOT NULL, 
	[intParentGroupId] INT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCommodityGroup] PRIMARY KEY ([intCommodityGroupId]), 
    CONSTRAINT [FK_tblICCommodityGroup_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityGroup',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Parent Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityGroup',
    @level2type = N'COLUMN',
    @level2name = N'intParentGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityGroup',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Commodity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityGroup',
    @level2type = N'COLUMN',
    @level2name = N'intCommodityId'