CREATE TABLE [dbo].[tblICInventoryShipmentItemAllocatedCharge]
(
	[intInventoryShipmentItemAllocatedChargeId] INT NOT NULL IDENTITY, 
	[intInventoryShipmentId] INT NOT NULL,
	[intInventoryShipmentChargeId] INT NOT NULL,
	[intInventoryShipmentItemId] INT NOT NULL, 
	[intEntityVendorId] INT NULL, 
	[dblAmount] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[ysnPrice] BIT NULL DEFAULT ((0)),	
	CONSTRAINT [PK_tblICInventoryShipmentItemAllocatedCharge] PRIMARY KEY ([intInventoryShipmentItemAllocatedChargeId]),
	CONSTRAINT [FK_tblICInventoryShipmentItemAllocatedCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryShipmentItemAllocatedCharge_tblICInventoryShipment] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryShipmentItemAllocatedCharge_intInventoryShipmentId_intChargeId_intInventoryShipmentChargeId]
	ON [dbo].[tblICInventoryShipmentItemAllocatedCharge]([intInventoryShipmentId] ASC, [intEntityVendorId] ASC, [ysnAccrue] ASC)
	INCLUDE (dblAmount);