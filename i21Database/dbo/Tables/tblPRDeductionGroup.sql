CREATE TABLE [dbo].[tblPRDeductionGroup](
	[intDeductionGroupId] [int] IDENTITY(1,1) NOT NULL,
	[strDeductionGroup] [nvarchar](50) NOT NULL,
	[strDescription] [nvarchar](50) NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRDeductionGroup] PRIMARY KEY ([intDeductionGroupId]), 
    CONSTRAINT [AK_tblPRDeductionGroup_strDeductionGroup] UNIQUE ([strDeductionGroup])
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroup',
    @level2type = N'COLUMN',
    @level2name = N'intDeductionGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroup',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Deduction Group Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRDeductionGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDeductionGroup'