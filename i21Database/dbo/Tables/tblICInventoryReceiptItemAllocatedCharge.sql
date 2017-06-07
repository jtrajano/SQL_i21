CREATE TABLE [dbo].[tblICInventoryReceiptItemAllocatedCharge]
(
	[intInventoryReceiptItemAllocatedChargeId] INT NOT NULL IDENTITY, 
	[intInventoryReceiptId] INT NOT NULL,
	[intInventoryReceiptChargeId] INT NOT NULL,
	[intInventoryReceiptItemId] INT NOT NULL, 
	[intEntityVendorId] INT NULL, 
	[dblAmount] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[ysnInventoryCost] BIT NULL DEFAULT ((0)),	
	[ysnPrice] BIT NULL DEFAULT ((0)),	
	--[dblAmountBilled] NUMERIC(18, 6) NULL DEFAULT ((0)), -- Removed these field. Use tblICInventoryReceiptCharge.dblAmountBilled
	--[dblAmountPaid] NUMERIC(18, 6) NULL DEFAULT ((0)), -- Removed these field. Use tblICInventoryReceiptCharge.dblAmountBilled
	CONSTRAINT [PK_tblICInventoryReceiptItemAllocatedCharge] PRIMARY KEY ([intInventoryReceiptItemAllocatedChargeId]),
	CONSTRAINT [FK_tblICInventoryReceiptItemAllocatedCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryReceiptItemAllocatedCharge_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptItemAllocatedCharge_intInventoryReceiptId_intChargeId_intInventoryReceiptChargeId]
	ON [dbo].[tblICInventoryReceiptItemAllocatedCharge]([intInventoryReceiptId] ASC, [intEntityVendorId] ASC, [ysnAccrue] ASC)
	INCLUDE (dblAmount, ysnInventoryCost);