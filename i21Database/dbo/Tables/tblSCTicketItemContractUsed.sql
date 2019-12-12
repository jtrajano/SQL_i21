CREATE TABLE [dbo].[tblSCTicketItemContractUsed] 
(
	[intItemTicketContractUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intItemContractDetailId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketItemContractUsed_intItemTicketContractUsedId] PRIMARY KEY ([intItemTicketContractUsedId]), 
    CONSTRAINT [FK_tblSCTicketItemContractUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
    CONSTRAINT [FK_tblSCTicketItemContractUsed_tblCTItemContractDetail_intItemContractDetailId] FOREIGN KEY (intItemContractDetailId) REFERENCES [tblCTItemContractDetail](intItemContractDetailId),
	CONSTRAINT [FK_tblSCTicketItemContractUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
