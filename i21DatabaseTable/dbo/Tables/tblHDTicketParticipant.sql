CREATE TABLE [dbo].[tblHDTicketParticipant]
(
	[intTicketParticipantId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[intEntityContactId] [int] NULL,
	[intTicketId] [int] NOT NULL,
	[ysnAddCalendarEvent] [bit] NOT NULL default 0,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketParticipant] PRIMARY KEY CLUSTERED ([intTicketParticipantId] ASC),
	CONSTRAINT [AK_tblEMEntity_tblHDTicket] UNIQUE ([intTicketId],[intEntityId]),
    CONSTRAINT [FK_tblHDTicketParticipant_tblHDTicket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade,
    CONSTRAINT [FK_tblHDTicketParticipant_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblHDTicketParticipant_tblEMEntity_intEntityContactId] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
