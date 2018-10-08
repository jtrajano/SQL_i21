CREATE TABLE [dbo].[tblHDTimeEntryResources]
(
	[intTimeEntryResourcesId] [int] IDENTITY(1,1) NOT NULL,
	[intTimeEntryId] [int] NOT NULL,
	[intEntityId] [int] NULL,
	[intResourcesEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryResources_intTimeEntryResourcesId] PRIMARY KEY CLUSTERED ([intTimeEntryResourcesId] ASC),
	CONSTRAINT [FK_tblHDTimeEntryResources_tblHDTimeEntry_intTimeEntryId] FOREIGN KEY ([intTimeEntryId]) REFERENCES [dbo].[tblHDTimeEntry] ([intTimeEntryId]),
	CONSTRAINT [FK_tblHDTimeEntryResources_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblHDTimeEntryResources_tblEMEntity_intResourcesEntityId] FOREIGN KEY ([intResourcesEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
