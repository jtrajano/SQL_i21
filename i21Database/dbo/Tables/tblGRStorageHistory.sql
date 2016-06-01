CREATE TABLE [dbo].[tblGRStorageHistory]
(
	[intStorageHistoryId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [intCustomerStorageId] INT NOT NULL, 
    [intTicketId] INT NULL, 
    [intInventoryReceiptId] INT NULL, 
    [intInvoiceId] INT NULL, 
	[intSalesOrderId] INT NULL, 
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
    CONSTRAINT [PK_tblGRStorageHistory_intStorageHistoryId] PRIMARY KEY ([intStorageHistoryId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [dbo].[tblGRCustomerStorage] ([intCustomerStorageId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRStorageHistory_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),	
	CONSTRAINT [FK_tblGRStorageHistory_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),	
	CONSTRAINT [FK_tblGRStorageHistory_tblARInvoice_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblSOSalesOrder_intSalesOrderId] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId]),
	CONSTRAINT [FK_tblGRStorageHistory_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId])
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
    @level2name = 'intContractHeaderId'
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