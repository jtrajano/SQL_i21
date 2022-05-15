CREATE TABLE [dbo].[tblHDTimeEntry]
(
	[intTimeEntryId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[dtmDateFrom] [datetime] NULL,
	[dtmDateTo] [datetime] NULL,
	[intTimeEntryPeriodDetailId]			INT NULL,
	[strComment]  NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntry_intTimeEntryId] PRIMARY KEY CLUSTERED ([intTimeEntryId] ASC),
	CONSTRAINT [FK_tblHDTimeEntry_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblHDTimeEntry_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] FOREIGN KEY ([intTimeEntryPeriodDetailId]) REFERENCES [dbo].[tblHDTimeEntryPeriodDetail] ([intTimeEntryPeriodDetailId])
)
