CREATE TABLE [dbo].[tblAPForClearing]
(
	[intClearingId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intInventoryReceiptItemId]		INT NULL,
	[intInventoryReceiptChargeId]	INT NULL,
	[intInventoryShipmentChargeId]	INT NULL,
	[intLoadShipmentDetailId]		INT NULL,
	[intCustomerStorageId]			INT NULL,
	[intItemId]						INT NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_tblAPForClearing_voucherPayable]
    ON [dbo].[tblAPForClearing]([intInventoryReceiptItemId]
								,[intInventoryReceiptChargeId]
								,[intInventoryShipmentChargeId]
								,[intLoadShipmentDetailId]
								,[intCustomerStorageId]
								,[intItemId] DESC);