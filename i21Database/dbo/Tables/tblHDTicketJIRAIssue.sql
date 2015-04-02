CREATE TABLE [dbo].[tblHDTicketJIRAIssue]
(
	[intTicketJIRAIssueId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strKey] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketJIRAIssue] PRIMARY KEY CLUSTERED ([intTicketJIRAIssueId] ASC),
    CONSTRAINT [FK_Ticket_icketJIRAIssue] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])
)

GO
CREATE INDEX [IX_tblHDTicketJIRAIssue_intTicketId] ON [dbo].[tblHDTicketJIRAIssue] ([intTicketId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketJIRAIssue',
    @level2type = N'COLUMN',
    @level2name = N'intTicketJIRAIssueId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketJIRAIssue',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'JIRA Key (Issue Key)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketJIRAIssue',
    @level2type = N'COLUMN',
    @level2name = N'strKey'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblHDTicketJIRAIssue',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'