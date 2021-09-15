CREATE TABLE [dbo].[tblSCTicketStorageUsed]
(
	[intTicketStorageUsedId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NULL, 
    [intEntityId] INT NULL, 
	[intStorageTypeId] INT NULL, 
	[intStorageScheduleId] INT NULL,
    [dblQty] DECIMAL(38,20) NULL,
	[ysnCustomerStorage] BIT NULL,
	[intContractDetailId] INT NULL, 
	CONSTRAINT [PK_tblSCTicketStorageUsed_intTicketStorageUsedId] PRIMARY KEY ([intTicketStorageUsedId]), 
	CONSTRAINT [FK_tblSCTicketStorageUsed_tblEMEntity_intEntityId] FOREIGN KEY (intEntityId) REFERENCES [tblEMEntity](intEntityId)
)
