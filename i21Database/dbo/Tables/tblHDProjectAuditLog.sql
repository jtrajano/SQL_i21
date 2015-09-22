CREATE TABLE [dbo].[tblHDProjectAuditLog]
(
	[intProjectAuditLogId] [int] IDENTITY(1,1) NOT NULL,
	[intProjectId] [int] NOT NULL,
	[intLinkId] [int] NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[intLastUpdatedByEnityId] [int] NOT NULL,
	[dtmLastUpdated] [datetime] NOT NULL,
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDProjectAuditLog] PRIMARY KEY CLUSTERED ([intProjectAuditLogId] ASC),
    CONSTRAINT [FK_tblHDProject_tblHDProjectAuditLog] FOREIGN KEY ([intProjectId]) REFERENCES [dbo].[tblHDProject] ([intProjectId]) on delete cascade
)
