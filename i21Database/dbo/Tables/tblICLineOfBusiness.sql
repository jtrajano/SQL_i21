CREATE TABLE [dbo].[tblICLineOfBusiness]
(
	[intLineOfBusinessId] INT NOT NULL IDENTITY, 
    [strLineOfBusiness] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICLineOfBusiness] PRIMARY KEY ([intLineOfBusinessId]), 
    CONSTRAINT [AK_tblICLineOfBusiness_strLineOfBusiness] UNIQUE ([strLineOfBusiness])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'intLineOfBusinessId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line Of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'strLineOfBusiness'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICLineOfBusiness',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'