CREATE TABLE [dbo].[tblHDGroupUserConfig]
(
	[intGroupUserConfigId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketGroupId] [int] NOT NULL,
	[intUserSecurityId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	PRIMARY KEY CLUSTERED (	[intGroupUserConfigId] ASC),
	CONSTRAINT [UNQ_tblHDGroupUserConfig] UNIQUE ([intTicketGroupId],[intUserSecurityId]),
    CONSTRAINT [FK_GroupUserConfig_TicketGroup] FOREIGN KEY ([intTicketGroupId]) REFERENCES [dbo].[tblHDTicketGroup] ([intTicketGroupId]) on delete cascade
)
