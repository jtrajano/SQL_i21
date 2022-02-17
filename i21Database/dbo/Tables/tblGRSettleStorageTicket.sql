CREATE TABLE [dbo].[tblGRSettleStorageTicket]
(
	[intSettleStorageTicketId] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NULL, 
	[intSettleStorageId] INT NOT NULL,
    [intCustomerStorageId] INT NULL,
	[dblUnits] DECIMAL(24, 10) NULL,
	[intChargeAndPremiumId] INT NULL,
	CONSTRAINT [PK_tblGRSettleStorageTicket_intSettleStorageTicketId] PRIMARY KEY ([intSettleStorageTicketId]),
	CONSTRAINT [FK_tblGRSettleStorageTicket_tblGRSettleStorage_intSettleStorageId] FOREIGN KEY ([intSettleStorageId]) REFERENCES [dbo].[tblGRSettleStorage] ([intSettleStorageId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_tblGRSettleStorageTicket_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [tblGRCustomerStorage]([intCustomerStorageId]),	
	CONSTRAINT [FK_tblGRSettleStorageTicket_tblGRChargeAndPremiumId_intChargeAndPremiumId] FOREIGN KEY ([intChargeAndPremiumId]) REFERENCES [tblGRChargeAndPremiumId]([intChargeAndPremiumId])
)

GO

CREATE NONCLUSTERED INDEX IX_tblGRSettleStorageTicket_intSettleStorageId 
	ON tblGRSettleStorageTicket (intSettleStorageId ASC);

GO

CREATE NONCLUSTERED INDEX IX_tblGRSettleStorageTicket_intCustomerStorageId
ON tblGRSettleStorageTicket (intCustomerStorageId ASC);

GO