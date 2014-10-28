CREATE TABLE [dbo].[tblHDTicketEscalation]
(
		[intTicketEscalationId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[dtmRequested] [datetime] NOT NULL,
	[intRequestedByEntityId] [int] NOT NULL,
	[dtmResponded] [datetime] NULL,
	[intRespondedByEntityId] [int] NULL,
	[ysnResponded] [bit] NULL,
	[intConcurrencyId] [int] NOT NULL,
 CONSTRAINT [PK_tblHDTicketEscalation] PRIMARY KEY CLUSTERED ([intTicketEscalationId] ASC),
 CONSTRAINT [FK_Escalation_Ticket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]),
 CONSTRAINT [FK_Create_Escalation_Entity] FOREIGN KEY ([intRequestedByEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
 CONSTRAINT [FK_Response_Escalation_Entity] FOREIGN KEY ([intRespondedByEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId])
)
