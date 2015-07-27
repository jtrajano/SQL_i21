CREATE TABLE [dbo].[tblICInventoryReceiptItemAllocatedCharge]
(
	[intInventoryReceiptItemAllocatedChargeId] INT NOT NULL IDENTITY, 
	[intInventoryReceiptId] INT NOT NULL,
	[intInventoryReceiptChargeId] INT NOT NULL,
	[intInventoryReceiptItemId] INT NOT NULL, 
	[intEntityVendorId] INT NULL, 
	[dblAmount] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[strCostBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ysnInventoryCost] BIT NULL DEFAULT ((0)),	
	CONSTRAINT [PK_tblICInventoryReceiptItemAllocatedCharge] PRIMARY KEY ([intInventoryReceiptItemAllocatedChargeId]), 
	CONSTRAINT [FK_tblICInventoryReceiptItemAllocatedCharge_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblICInventoryReceiptItemAllocatedCharge_tblICInventoryReceiptCharge] FOREIGN KEY ([intInventoryReceiptChargeId]) REFERENCES [tblICInventoryReceiptCharge]([intInventoryReceiptChargeId]), 
	CONSTRAINT [FK_tblICInventoryReceiptItemAllocatedCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptItemAllocatedCharge_intInventoryReceiptId_intChargeId_intInventoryReceiptChargeId]
	ON [dbo].[tblICInventoryReceiptItemAllocatedCharge]([intInventoryReceiptId] ASC, [intEntityVendorId] ASC, [strCostBilledBy] ASC)
	INCLUDE (dblAmount, ysnInventoryCost);