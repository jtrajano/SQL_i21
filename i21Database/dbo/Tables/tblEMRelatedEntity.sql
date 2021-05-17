CREATE TABLE [dbo].[tblEMRelatedEntity]
(
	[intRelatedEntityId]				INT NOT NULL PRIMARY KEY IDENTITY,
    [intEntityId]						INT NOT NULL,
    [strEntityName]						NVARCHAR(500) COLLATE Latin1_General_CI_AS  NOT NULL,
    [intConcurrencyId]					INT NOT NULL DEFAULT 1, 

    CONSTRAINT [FK_tblEMRelatedEntity_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [UK_tblEMRelatedEntity_Column] UNIQUE ([strEntityName])
)
