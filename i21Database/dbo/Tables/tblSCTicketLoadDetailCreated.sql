CREATE TABLE [dbo].[tblSCTicketLoadDetailCreated]
(
	[intTicketLoadDetailCreatedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intLoadDetailId] INT NULL, 
    [dblQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketLoadDetailCreated_intTicketId] PRIMARY KEY ([intTicketLoadDetailCreatedId]), 
    CONSTRAINT [FK_tblSCTicketLoadDetailCreated_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
    CONSTRAINT [FK_tblSCTicketLoadDetailCreated_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY (intLoadDetailId) REFERENCES [tblLGLoadDetail](intLoadDetailId),
)
