CREATE TABLE [dbo].[tblSMCacheVersion]
(
	[intCacheVersionId]		INT												NOT NULL PRIMARY KEY IDENTITY,
	[intEntityId]			[int]											NULL,
	[strType]				[nvarchar](50)	COLLATE Latin1_General_CI_AS	NOT NULL,
	[intVersion]			[int]											NOT NULL,
	[intConcurrencyId]		[int]											NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMCacheVersion_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]) ON DELETE CASCADE
)
