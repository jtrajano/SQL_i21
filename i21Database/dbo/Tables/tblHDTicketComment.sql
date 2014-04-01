CREATE TABLE [dbo].[tblHDTicketComment]
(
	[intTicketCommentId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strComment] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketComment] PRIMARY KEY CLUSTERED ([intTicketCommentId] ASC),
    CONSTRAINT [FK_TicketComment_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId])
)
