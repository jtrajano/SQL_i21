CREATE TABLE [dbo].[tblSCTicketStorageUsed]
(
	[intTicketStorageUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intStorageTypeId] INT NULL, 
    [intStorageScheduleId] INT NULL, 
    [intEntityId] INT NULL, 
    [dblQty] DECIMAL(18, 6) NULL,
	CONSTRAINT [PK_tblSCTicketStorageUsed_intTicketSpotUsedId] PRIMARY KEY ([intTicketStorageUsedId]), 
    CONSTRAINT [FK_tblSCTicketStorageUsed_tblSCTicket_intTicketId] FOREIGN KEY (intTicketId) REFERENCES [tblSCTicket](intTicketId),
	CONSTRAINT [FK_tblSCTicketStorageUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
