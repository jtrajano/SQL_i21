CREATE TABLE [dbo].[tblHDTimeEntry]
(
	[intTimeEntryId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntry_intTimeEntryId] PRIMARY KEY CLUSTERED ([intTimeEntryId] ASC),
	CONSTRAINT [FK_tblHDTimeEntry_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
