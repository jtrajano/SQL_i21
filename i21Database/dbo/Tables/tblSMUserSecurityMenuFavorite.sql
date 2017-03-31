CREATE TABLE [dbo].[tblSMUserSecurityMenuFavorite]
(
	[intUserSecurityMenuFavoriteId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intMenuId] INT NOT NULL, 
	[intEntityUserSecurityId] INT NULL, 
	[intCompanyLocationId] INT NULL, 
    [intSort] INT NULL DEFAULT (1), 
	[intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMasterMenu] FOREIGN KEY ([intMenuId]) REFERENCES [tblSMMasterMenu]([intMenuID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) ON DELETE CASCADE
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
    @level2name = N'intMenuId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intEntityUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Company Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityMenuFavorite',
    @level2type = N'COLUMN',
    @level2name = N'intCompanyLocationId'
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