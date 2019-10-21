CREATE TABLE [dbo].[tblHDProjectDetail]
(
	[intProjectDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intDetailProjectId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblHDProjectDetail_intProjectDetailId] PRIMARY KEY CLUSTERED ([intProjectDetailId] ASC),
	CONSTRAINT [UK_tblHDProjectDetail_intParentProjectId_intDetailProjectId] UNIQUE ([intProjectId],[intDetailProjectId]),
    CONSTRAINT [FK_tblHDProjectDetail_tblHDProject_intProjectId] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade,
    CONSTRAINT [FK_tblHDProjectDetail_tblHDProject_intDetailProjectId] FOREIGN KEY ([intDetailProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId])
)
