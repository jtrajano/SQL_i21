CREATE TABLE [dbo].[tblSCTicketContractUsed]
(
	[intTicketContractUsed] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intContractDetailId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblScheduleQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketContractUsed_intTicketId] PRIMARY KEY ([intTicketContractUsed]), 
    CONSTRAINT [FK_tblSCTicketContractUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
    CONSTRAINT [FK_tblSCTicketContractUsed_tblCTContractDetail_intContractId] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId),
	CONSTRAINT [FK_tblSCTicketContractUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicketContractUsed_7_2068775023__K2_K3] ON [dbo].[tblSCTicketContractUsed]
(
	[intTicketId] ASC,
	[intContractDetailId] ASC
)

GO
