CREATE TABLE [dbo].[tblPRPayGroup]
(
	[intPayGroupId] INT NOT NULL IDENTITY, 
    [strPayGroup] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
    [strPayPeriod] NVARCHAR(50) NOT NULL DEFAULT ('Bi-Weekly'), 
	[ysnActive] BIT NOT NULL DEFAULT ((1)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRPayGroup] PRIMARY KEY ([intPayGroupId]), 
    CONSTRAINT [AK_tblPRPayGroup_strPayGroup] UNIQUE ([strPayGroup]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intPayGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Group',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'strPayGroup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pay Period',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'strPayPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Active',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'ysnActive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRPayGroup',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'