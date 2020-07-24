CREATE TABLE [dbo].[tblGRStorageInventoryReceipt]
(
	[intStorageInventoryReceipt] INT IDENTITY(1,1)
	,[intCustomerStorageId] INT NOT NULL
	,[intInventoryReceiptId] INT NOT NULL
	,[intInventoryReceiptItemId] INT NOT NULL
	,[intContractDetailId] INT NULL
	,[dblUnits] DECIMAL(38,20) NOT NULL
	,[dblShrinkage] DECIMAL(38,20)
	,[dblNetUnits] DECIMAL(38,20)
	,[intSettleStorageId] INT NULL
	,[intTransferStorageReferenceId] INT NULL
	,[dblTransactionUnits] DECIMAL(38,20) NULL
	,[dblReceiptRunningUnits] DECIMAL(24,10) NULL
	,[ysnUnposted] BIT DEFAULT 0
	,CONSTRAINT [PK_tblGRStorageInventoryReceipt_intStorageInventoryReceipt] PRIMARY KEY ([intStorageInventoryReceipt])
	,CONSTRAINT [FK_tblGRStorageInventoryReceipt_tblICInventoryReceipt_intInventoryReceiptId] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [dbo].[tblICInventoryReceipt] ([intInventoryReceiptId])
	,CONSTRAINT [FK_tblGRStorageInventoryReceiptItem_tblICInventoryReceiptItem_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [dbo].[tblICInventoryReceiptItem] ([intInventoryReceiptItemId])
	,CONSTRAINT [FK_tblGRStorageInventoryReceiptItem_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId])
)