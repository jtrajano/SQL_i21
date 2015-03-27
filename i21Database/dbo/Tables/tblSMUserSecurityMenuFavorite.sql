CREATE TABLE [dbo].[tblSMUserSecurityMenuFavorite]
(
	[intUserSecurityMenuFavoriteId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleMenuId] INT NOT NULL, 
	[intUserSecurityId] INT NOT NULL, 
    [intSort] INT NULL DEFAULT (1), 
	[intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMUserRoleMenu] FOREIGN KEY ([intUserRoleMenuId]) REFERENCES [tblSMUserRoleMenu]([intUserRoleMenuId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE
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
    @value = N'User Role Menu Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
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