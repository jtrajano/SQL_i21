CREATE TABLE [dbo].[tblGRStorageHistory]
(
	[intStorageHistoryId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intCustomerStorageId] INT NOT NULL, 
    [intTicketId] INT NULL, 
    [intInventoryReceiptId] INT NULL, 
    [intInvoiceId] INT NULL, 
    [intContractDetailId] INT NULL, 
    [dblUnits] NUMERIC(11, 3) NOT NULL, 
    [dtmHistoryDate] DATETIME NULL, 
    [dblStoragePaid] NUMERIC(9, 6) NULL, 
    [dblFeesPaid] NUMERIC(7, 2) NULL, 
    [dblCurrencyRate] NUMERIC(15, 8) NULL, 
    CONSTRAINT [PK_tblGRStorageHistory_intStorageHistoryId] PRIMARY KEY ([intStorageHistoryId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [dbo].[tblGRCustomerStorage] ([intCustomerStorageId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblICInventoryReceipt_intInventoryReceiptId] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [dbo].[tblICInventoryReceipt] ([intInventoryReceiptId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'intStorageHistoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Storage Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerStorageId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Receipt Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryReceiptId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Invoice Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'intInvoiceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contract Sequence Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = 'intContractDetailId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Currency Rate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblCurrencyRate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fees Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblFeesPaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Storage Paid',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblStoragePaid'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'History Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'dtmHistoryDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblGRStorageHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblUnits'