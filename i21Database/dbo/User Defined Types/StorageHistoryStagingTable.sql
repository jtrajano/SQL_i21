CREATE TYPE [dbo].[StorageHistoryStagingTable] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED,
    [intCustomerStorageId] INT NOT NULL,
    [intSettleStorageId] INT NULL,
    [intTransferStorageId] INT NULL,
	[intTicketId] INT NULL,
    [intDeliverySheetId] INT NULL,
	[intInventoryReceiptId] INT NULL,
	[intInvoiceId] INT NULL,
	[intInventoryShipmentId] INT NULL,
    [intBillId] INT NULL,
	[intContractHeaderId] INT NULL,
    [intInventoryAdjustmentId] INT NULL,
    [dblUnits] NUMERIC(38,20) NULL,
	[dtmHistoryDate] DATETIME NULL,
    [dblPaidAmount] NUMERIC(38,20) NULL,
    [dblCurrencyRate] NUMERIC(38, 20) NULL,
    [intUserId] INT NOT NULL,
    [ysnPost] BIT NOT NULL,
    [intTransactionTypeId] INT NOT NULL,
    [strPaidDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS
)