CREATE TABLE [dbo].[tblQMPriorityGroup]
(
	[intPriorityGroupId]	INT NOT NULL IDENTITY,
	[intSortId]				INT NOT NULL,
	[intConcurrencyId]		INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblQMPriorityGroup_intPriorityGroupId] PRIMARY KEY CLUSTERED ([intPriorityGroupId] ASC),
	CONSTRAINT [UK_tblQMPriorityGroup_intSortId] UNIQUE (intSortId)
);