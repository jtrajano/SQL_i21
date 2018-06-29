CREATE TABLE [dbo].[tblSCTicketContractUsed]
(
	[intTicketContractUsed] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intContractDetailId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblScheduleQty] DECIMAL(13, 5) NULL,
	CONSTRAINT [PK_tblSCTicketContractUsed_intTicketId] PRIMARY KEY ([intTicketContractUsed]), 
    CONSTRAINT [FK_tblSCTicketContractUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
    CONSTRAINT [FK_tblSCTicketContractUsed_tblCTContractDetail_intContractId] FOREIGN KEY (intContractDetailId) REFERENCES [tblCTContractDetail](intContractDetailId),
	CONSTRAINT [FK_tblSCTicketContractUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
