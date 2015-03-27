CREATE TABLE [dbo].[tblSMEntityMenuFavorite]
(
    [intUserSecurityMenuFavoriteId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityMenuId] INT NOT NULL, 
	[intUserSecurityId] INT NOT NULL, 
    [intSort] INT NULL DEFAULT (1), 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)
