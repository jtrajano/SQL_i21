CREATE TABLE [dbo].[tblSMEntityMenuFavorite]
(
    [intEntityMenuFavoriteId]				INT NOT NULL PRIMARY KEY IDENTITY, 
	[strMenuName]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
    [intMenuId]								INT NULL,
	[intCustomId]							INT NULL, 
	[intEntityId]							INT NOT NULL, 
	[intCompanyLocationId]					INT NULL, 
	[intParentEntityMenuFavoriteId]			INT NULL,
    [intSort]								INT NULL DEFAULT (1), 
	[ysnCustomView]							BIT NOT NULL DEFAULT (0), 
	[ysnMenuLink]							BIT NOT NULL DEFAULT (0),
	[strMenuLinkCommand]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]						INT NOT NULL DEFAULT (1), 

    CONSTRAINT [FK_tblSMEntityMenuFavorite_tblSMasterMenu] FOREIGN KEY ([intMenuId]) REFERENCES [tblSMMasterMenu]([intMenuID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMEntityMenuFavorite_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMEntityMenuFavorite_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) ON DELETE CASCADE
)