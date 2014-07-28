CREATE TABLE [dbo].[tblSMUserSecurityMenuFavorite]
(
	[intUserSecurityMenuFavoriteId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityMenuId] INT NOT NULL, 
    [intSort] INT NULL DEFAULT (1), 
	[intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu] FOREIGN KEY ([intUserSecurityMenuId]) REFERENCES [tblSMUserSecurityMenu]([intUserSecurityMenuId]) ON DELETE CASCADE
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityMenuFavoriteId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Menu Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'