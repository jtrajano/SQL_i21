CREATE TABLE [dbo].[tblICInventoryReceiptChargePerItem]
(
	[intInventoryReceiptChargePerItemId] INT NOT NULL IDENTITY, 
	[intInventoryReceiptId] INT NOT NULL,
    [intInventoryReceiptChargeId] INT NOT NULL, 
	[intInventoryReceiptItemId] INT NOT NULL, 
	[intChargeId] INT NOT NULL, 
	[intEntityVendorId] INT NULL, 
	[intContractId] INT NULL, 
	[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblICInventoryReceiptChargePerItem] PRIMARY KEY ([intInventoryReceiptChargePerItemId]), 
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]),
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblCTContractHeader] FOREIGN KEY ([intContractId]) REFERENCES [tblCTContractHeader]([intContractHeaderId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptChargePerItem_intInventoryReceiptId_intChargeId_intInventoryReceiptChargeId]
	ON [dbo].[tblICInventoryReceiptChargePerItem]([intInventoryReceiptId] ASC, [intChargeId] ASC, [intInventoryReceiptChargeId] ASC)
	INCLUDE (intEntityVendorId, intContractId, dblCalculatedAmount);


