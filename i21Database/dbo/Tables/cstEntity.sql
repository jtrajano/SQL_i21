CREATE TABLE [dbo].[cstEntity]
(
	[intId] INT NOT NULL,
    CONSTRAINT [PK_cstEntity] PRIMARY KEY CLUSTERED ([intId] ASC),
    CONSTRAINT [FK_cstEntity_tblEntity] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE
)
