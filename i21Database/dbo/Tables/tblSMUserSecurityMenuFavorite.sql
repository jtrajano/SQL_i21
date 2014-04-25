CREATE TABLE [dbo].[tblSMUserSecurityMenuFavorite]
(
	[intUserSecurityMenuFavoriteId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityMenuId] INT NOT NULL, 
    [intSort] INT NULL DEFAULT (1), 
	[intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityMenuFavorite_tblSMUserSecurityMenu] FOREIGN KEY ([intUserSecurityMenuId]) REFERENCES [tblSMUserSecurityMenu]([intUserSecurityMenuId]) ON DELETE CASCADE
)
