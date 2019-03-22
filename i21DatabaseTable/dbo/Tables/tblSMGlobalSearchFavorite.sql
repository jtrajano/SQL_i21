CREATE TABLE [dbo].[tblSMGlobalSearchFavorite]
(
	[intGSFavoriteId] INT Identity(1,1) NOT NULL ,
	[intGSIndexId] INT NOT NULL,
	[intEntityId] INT NOT NULL,
	dtmDateEntered DATETIME NOT NULL,
	[intVisitCount] INT NOT NULL DEFAULT 0,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblSMGlobalSearchFavorite] Primary key clustered (intGSFavoriteId ASC),
	CONSTRAINT [FK_tblSMGlobalSearchFavorite_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]) ,
	CONSTRAINT [FK_tblSMGlobalSearchFavorite_tblSMGlobalSearch_intGSIndexId] FOREIGN KEY ([intGSIndexId]) REFERENCES [tblSMGlobalSearch]([intGSIndexId]) 

)
