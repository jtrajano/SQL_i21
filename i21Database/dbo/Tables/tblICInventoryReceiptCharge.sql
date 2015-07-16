CREATE TABLE [dbo].[tblICInventoryReceiptCharge]
(
	[intInventoryReceiptChargeId] INT NOT NULL IDENTITY, 
    [intInventoryReceiptId] INT NOT NULL, 
	[intContractId] INT NULL,
    [intChargeId] INT NOT NULL, 
    [ysnInventoryCost] BIT NULL DEFAULT ((0)), 
    [strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit'), 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intCostUOMId] INT NULL, 
    [intEntityVendorId] INT NULL, 
    [dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strAllocateCostBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
    [strCostBilledBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Vendor'), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryReceiptCharge] PRIMARY KEY ([intInventoryReceiptChargeId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblICItem] FOREIGN KEY ([intChargeId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblICItemUOM] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)
