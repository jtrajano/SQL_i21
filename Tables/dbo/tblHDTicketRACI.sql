CREATE TABLE [dbo].[tblHDTicketRACI]
(
	[intTicketRACIId] [int] IDENTITY(1,1) NOT NULL,
	[intTicketId] [int] NOT NULL,
	[intResponsibleId] [int] NULL,
	[intCompanyEntityId] [int] NULL,
	[intThirdPartyEntityId] [int] NULL,
	[intEntityContactId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTicketRACI] PRIMARY KEY CLUSTERED ([intTicketRACIId] ASC),
    CONSTRAINT [FK_tblTicketRACI_tblEMEntity_intCompanyEntityId] FOREIGN KEY ([intCompanyEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblTicketRACI_tblEMEntity_intThirdPartyEntityId] FOREIGN KEY ([intThirdPartyEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblTicketRACI_tblEMEntity_intEntityContactId] FOREIGN KEY ([intEntityContactId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [FK_tblTicketRACI_tblHDTicket] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]) on delete cascade
)
