CREATE TABLE [dbo].[tblEMEntityEFTHeader]
(
	[intEntityEFTHeaderId]		INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]				INT            NOT NULL,
	[intConcurrencyId]          INT            NOT NULL,

	CONSTRAINT [PK_tblEMEntityEFTHeader] PRIMARY KEY CLUSTERED ([intEntityEFTHeaderId] ASC),
	CONSTRAINT [FK_tblEMEntityEFTHeader_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)
