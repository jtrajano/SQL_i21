CREATE TABLE [dbo].[tblHDTicketWatcher]
(
	[intTicketWatcherId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intUserId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketWatcher] PRIMARY KEY CLUSTERED ([intTicketWatcherId] ASC),
    CONSTRAINT [FK_TicketWatcher_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)
