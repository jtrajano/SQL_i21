CREATE TABLE [dbo].[tblICInventoryShipmentChargePerItem]
(
	[intInventoryShipmentChargePerItemId] INT NOT NULL IDENTITY, 
	[intInventoryShipmentId] INT NOT NULL,
    [intInventoryShipmentChargeId] INT NOT NULL, 
	[intInventoryShipmentItemId] INT NULL, -- Change this to nullable. Fixed amount is not applied to an item. 
	[intChargeId] INT NOT NULL, 
	[intEntityVendorId] INT NULL, 
	[intContractId] INT NULL,
	[intContractDetailId] INT NULL,   
	[dblCalculatedAmount] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[strAllocatePriceBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[ysnPrice] BIT NULL DEFAULT ((0)),
	CONSTRAINT [PK_tblICInventoryShipmentChargePerItem] PRIMARY KEY ([intInventoryShipmentChargePerItemId]), 
	CONSTRAINT [FK_tblICInventoryShipmentChargePerItem_tblICInventoryShipmentItem] FOREIGN KEY ([intInventoryShipmentItemId]) REFERENCES [tblICInventoryShipmentItem]([intInventoryShipmentItemId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblICInventoryShipmentChargePerItem_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]),
	CONSTRAINT [FK_tblICInventoryShipmentChargePerItem_tblCTContractHeader] FOREIGN KEY ([intContractId]) REFERENCES [tblCTContractHeader]([intContractHeaderId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryShipmentChargePerItem_intInventoryShipmentId_intChargeId_intInventoryShipmentChargeId]
	ON [dbo].[tblICInventoryShipmentChargePerItem]([intInventoryShipmentId] ASC, [intChargeId] ASC, [intInventoryShipmentChargeId] ASC)
	INCLUDE (intEntityVendorId, intContractId, dblCalculatedAmount, strAllocatePriceBy, ysnAccrue, ysnPrice);