CREATE TABLE [dbo].[tblSCTicketLoadUsed]
(
	[intTicketLoadUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intLoadDetailId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketLoadUsed_intTicketId] PRIMARY KEY ([intTicketLoadUsedId]), 
    CONSTRAINT [FK_tblSCTicketLoadUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
    CONSTRAINT [FK_tblSCTicketLoadUsed_tblCTContractDetail_intLoadDetailId] FOREIGN KEY (intLoadDetailId) REFERENCES [tblLGLoadDetail](intLoadDetailId),
	CONSTRAINT [FK_tblSCTicketLoadUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
GO

CREATE NONCLUSTERED INDEX [IX_tblSCTicketLoadUsed_intLoadDetailId]
ON [dbo].[tblSCTicketLoadUsed] ([intLoadDetailId])
GO