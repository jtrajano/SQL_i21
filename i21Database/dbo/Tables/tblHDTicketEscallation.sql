CREATE TABLE [dbo].[tblHDTicketEscallation]
(
	[intTicketEscallationId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[dtmRequested] [datetime] NOT NULL,
	[intRequestedByEntityId] [int] NOT NULL,
	[dtmResponded] [datetime] NULL,
	[intRespondedByEntityId] [int] NULL,
	[ysnResponded] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketEscallation] PRIMARY KEY CLUSTERED ([intTicketEscallationId] ASC),
 CONSTRAINT [FK_Escallation_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]),
 CONSTRAINT [FK_Create_Escallation_Entity] FOREIGN KEY ([intRequestedByEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
 CONSTRAINT [FK_Response_Escallation_Entity] FOREIGN KEY ([intRespondedByEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
)
