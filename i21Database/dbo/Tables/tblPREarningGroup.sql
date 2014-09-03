CREATE TABLE [dbo].[tblPREarningGroup](
	[intEarningGroupId] [int] IDENTITY(1,1) NOT NULL,
	[strEarningGroup] [nvarchar](50) NOT NULL,
	[strDescription] [nvarchar](50) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREarningGroup] PRIMARY KEY ([intEarningGroupId]), 
    CONSTRAINT [AK_tblPREarningGroup_strEarningGroup] UNIQUE ([strEarningGroup]),
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroup',
    @level2type = N'COLUMN',
    @level2name = N'intEarningGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Earning Group Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroup',
    @level2type = N'COLUMN',
    @level2name = N'strEarningGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroup',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPREarningGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'