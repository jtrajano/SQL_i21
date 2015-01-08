CREATE TABLE [dbo].[tblHDTicketHistory]
(
	[intTicketHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strField] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strLabel] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strOldValue] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[strNewValue] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmChangeDate] DATETIME NULL,
	[intChangeByEntityId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketHistory] PRIMARY KEY CLUSTERED ([intTicketHistoryId] ASC),
    CONSTRAINT [FK_TicketHistory_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)
