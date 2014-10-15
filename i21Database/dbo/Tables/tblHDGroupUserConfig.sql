CREATE TABLE [dbo].[tblHDGroupUserConfig]
(
	[intGroupUserConfigId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketGroupId] [int] NOT NULL,
	[intUserSecurityId] [int] NOT NULL,
	[intUserSecurityEntityId] [int] NULL,
	[ysnOwner] BIT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	PRIMARY KEY CLUSTERED (	[intGroupUserConfigId] ASC),
	CONSTRAINT [UNQ_tblHDGroupUserConfig] UNIQUE ([intTicketGroupId],[intUserSecurityId]),
    CONSTRAINT [FK_GroupUserConfig_TicketGroup] FOREIGN KEY ([intTicketGroupId]) REFERENCES [dbo].[tblHDTicketGroup] ([intTicketGroupId]) on delete cascade
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDGroupUserConfig',
    @level2type = N'COLUMN',
    @level2name = N'intGroupUserConfigId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDGroupUserConfig',
    @level2type = N'COLUMN',
    @level2name = N'intTicketGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDGroupUserConfig',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDGroupUserConfig',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Owner',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDGroupUserConfig',
    @level2type = N'COLUMN',
    @level2name = N'ysnOwner'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDGroupUserConfig',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'