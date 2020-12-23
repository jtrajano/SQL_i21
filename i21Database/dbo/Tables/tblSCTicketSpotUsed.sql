CREATE TABLE [dbo].[tblSCTicketSpotUsed]
(
	[intTicketSpotUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [dblBasis] DECIMAL(18, 6) NULL, 
    [dblFuture] DECIMAL(18, 6) NULL, 
    [intEntityId] INT NULL, 
    [dblQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketSpotUsed_intTicketSpotUsedId] PRIMARY KEY ([intTicketSpotUsedId]), 
    CONSTRAINT [FK_tblSCTicketSpotUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
	CONSTRAINT [FK_tblSCTicketSpotUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
