CREATE TABLE [dbo].[tblGRSettleStorageBillDetail]
(
	[intSettleStorageBillDetailId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	[intSettleStorageId] INT NOT NULL,
	[intBillId] INT NOT NULL,
	[ysnImport] BIT NULL,
	CONSTRAINT [PK_tblGRSettleStorageBillDetail] PRIMARY KEY CLUSTERED ([intSettleStorageBillDetailId] ASC),
	CONSTRAINT [FK_tblGRSettleStorageBillDetail_tblGRSettleStorage_intSettleStorageId] FOREIGN KEY ([intSettleStorageId]) REFERENCES [dbo].tblGRSettleStorage ([intSettleStorageId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRSettleStorageBillDetail_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRSettleStorageBillDetail_intBillId]
ON [dbo].[tblGRSettleStorageBillDetail] ([intBillId])
GO