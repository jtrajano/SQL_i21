CREATE TABLE [dbo].[tblICInventoryShipmentCharge]
(
	[intInventoryShipmentChargeId] INT NOT NULL IDENTITY, 
    [intInventoryShipmentId] INT NOT NULL, 
    [intContractId] INT NULL,
    [intChargeId] INT NOT NULL, 
    [strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit'), 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intCostUOMId] INT NULL, 
    [dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[intEntityVendorId] INT NULL, 
	[ysnPrice] BIT NULL DEFAULT ((0)),
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryShipmentCharge] PRIMARY KEY ([intInventoryShipmentChargeId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblICItem] FOREIGN KEY ([intChargeId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblICItemLocation] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]) 
)
