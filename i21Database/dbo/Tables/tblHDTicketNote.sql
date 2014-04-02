CREATE TABLE [dbo].[tblHDTicketNote]
(
	[intTicketNoteId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strNote] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmCreated] [datetime] NULL,
	[dtmTime] [datetime] NULL,
	[intCreatedUserId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblHDTicketNote] PRIMARY KEY CLUSTERED ([intTicketNoteId] ASC),
    CONSTRAINT [FK_TicketNote_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)
