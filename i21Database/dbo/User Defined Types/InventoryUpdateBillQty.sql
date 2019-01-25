CREATE TYPE [dbo].[InventoryUpdateBillQty] AS TABLE(
	[intInventoryReceiptItemId] INT NULL,
	[intInventoryReceiptChargeId] INT NULL,
	[intInventoryShipmentChargeId] INT NULL,
	[strSourceTrasactionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NOT NULL,
	[intToBillUOMId] INT NULL,
	[dblToBillQty] NUMERIC(18,6) NULL DEFAULT((0))
)