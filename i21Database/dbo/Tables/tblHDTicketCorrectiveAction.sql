CREATE TABLE [dbo].[tblHDTicketCorrectiveAction]
(
	[intCorrectiveActionId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intCorrectiveActionTicketId] [int] not null,
	[intConcurrencyId] [int] NOT NULL,
	 CONSTRAINT [PK_tblHDTicketCorrectiveAction_intCorrectiveActionId] PRIMARY KEY CLUSTERED ([intCorrectiveActionId] ASC),
	 CONSTRAINT [UQ_tblHDTicket_intTicketId_intCorrectiveActionTicketId] UNIQUE ([intTicketId],[intCorrectiveActionTicketId])
)
