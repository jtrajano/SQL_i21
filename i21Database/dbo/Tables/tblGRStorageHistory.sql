﻿CREATE TABLE [dbo].[tblGRStorageHistory]
(
	[intStorageHistoryId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intCustomerStorageId] INT NOT NULL, 
    [intTicketId] INT NULL, 
    [intInventoryReceiptId] INT NULL, 
    [intInvoiceId] INT NULL, 
	[intInventoryShipmentId] INT NULL, 
	[intBillId] INT NULL, 
    [intContractHeaderId] INT NULL, 
    [dblUnits] NUMERIC(18, 6) NULL, 
    [dtmHistoryDate] DATETIME NULL, 
    [dblPaidAmount] NUMERIC(18, 6) NULL, 
    [strPaidDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [dblCurrencyRate] NUMERIC(18, 8) NULL, 
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strUserName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionTypeId] INT  NULL,
	[intEntityId] INT  NULL,
	[intCompanyLocationId] INT  NULL,
	[strTransferTicket] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[strSettleTicket] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[strVoucher] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[intSettleStorageId] INT NULL,
    CONSTRAINT [PK_tblGRStorageHistory_intStorageHistoryId] PRIMARY KEY ([intStorageHistoryId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [dbo].[tblGRCustomerStorage] ([intCustomerStorageId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRStorageHistory_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),	
	CONSTRAINT [FK_tblGRStorageHistory_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),	
	CONSTRAINT [FK_tblGRStorageHistory_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblICInventoryShipment_intInventoryShipmentId] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [dbo].[tblICInventoryShipment] ([intInventoryShipmentId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblGRSettleStorage_intSettleStorageId] FOREIGN KEY ([intSettleStorageId]) REFERENCES [dbo].[tblGRSettleStorage] ([intSettleStorageId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId])
)

GO

CREATE NONCLUSTERED INDEX [IX_tblGRStorageHistory_intCustomerStorageId] ON [dbo].[tblGRStorageHistory]
(
	[intCustomerStorageId] ASC
)
INCLUDE ( 	
	intStorageHistoryId
	,intTicketId
	,intInventoryReceiptId
	,intInvoiceId
	,intInventoryShipmentId
	,intBillId
	,intContractHeaderId
) 
GO 
