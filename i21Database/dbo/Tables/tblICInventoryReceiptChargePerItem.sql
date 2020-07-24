CREATE TABLE [dbo].[tblICInventoryReceiptChargePerItem]
(
	[intInventoryReceiptChargePerItemId] INT NOT NULL IDENTITY, 
	[intInventoryReceiptId] INT NOT NULL,
    [intInventoryReceiptChargeId] INT NOT NULL, 
	[intInventoryReceiptItemId] INT NULL, -- Change this to nullable. Fixed amount is not applied to an item. 
	[intChargeId] INT NOT NULL, 
	[intEntityVendorId] INT NULL, 
	[intContractId] INT NULL, 
	[intContractDetailId] INT NULL, 
	[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[dblCalculatedQty] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[strAllocateCostBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[ysnInventoryCost] BIT NULL DEFAULT ((0)),
	[ysnPrice] BIT NULL DEFAULT ((0)),
	[dblTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
	--[dblAmountBilled] NUMERIC(18, 6) NULL DEFAULT ((0)), -- Removed these field. Use tblICInventoryReceiptCharge.dblAmountBilled
	--[dblAmountPaid] NUMERIC(18, 6) NULL DEFAULT ((0)), -- Removed these field. Use tblICInventoryReceiptCharge.dblAmountBilled
	CONSTRAINT [PK_tblICInventoryReceiptChargePerItem] PRIMARY KEY ([intInventoryReceiptChargePerItemId]), 
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblICInventoryReceiptCharge] FOREIGN KEY ([intInventoryReceiptChargeId]) REFERENCES [tblICInventoryReceiptCharge]([intInventoryReceiptChargeId]), 
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]), 
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	CONSTRAINT [FK_tblICInventoryReceiptChargePerItem_tblCTContractHeader] FOREIGN KEY ([intContractId]) REFERENCES [tblCTContractHeader]([intContractHeaderId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptChargePerItem_intInventoryReceiptId_intChargeId_intInventoryReceiptChargeId]
	ON [dbo].[tblICInventoryReceiptChargePerItem]([intInventoryReceiptId] ASC, [intChargeId] ASC, [intInventoryReceiptChargeId] ASC)
	INCLUDE (intEntityVendorId, intContractId, dblCalculatedAmount, strAllocateCostBy, ysnAccrue, ysnInventoryCost, ysnPrice);

