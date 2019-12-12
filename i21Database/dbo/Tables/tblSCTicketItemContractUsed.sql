CREATE TABLE [dbo].[tblSCTicketContractUsed]
(
	[intItemTicketContractUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intItemContractDetailId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblScheduleQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketItemContractUsed_intItemTicketContractUsedId] PRIMARY KEY ([intItemTicketContractUsedId]), 
    CONSTRAINT [FK_tblSCTicketContractUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
    CONSTRAINT [FK_tblSCTicketContractUsed_tblCTItemContractDetail_intItemContractDetailId] FOREIGN KEY (intItemContractDetailId) REFERENCES [tblCTItemContractDetail](intItemContractDetailId),
	CONSTRAINT [FK_tblSCTicketContractUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
