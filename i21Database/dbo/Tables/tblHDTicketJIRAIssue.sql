CREATE TABLE [dbo].[tblHDTicketJIRAIssue]
(
	[intTicketJIRAIssueId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strKey] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketJIRAIssue] PRIMARY KEY CLUSTERED ([intTicketJIRAIssueId] ASC),
    CONSTRAINT [FK_Ticket_icketJIRAIssue] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])
)
