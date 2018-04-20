CREATE TABLE [dbo].[tblHDTimeEntry]
(
	[intTimeEntryId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntry_intTimeEntryId] PRIMARY KEY CLUSTERED ([intTimeEntryId] ASC)
)
