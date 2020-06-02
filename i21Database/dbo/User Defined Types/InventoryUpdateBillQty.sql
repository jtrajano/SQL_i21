CREATE TYPE [dbo].[InventoryUpdateBillQty] AS TABLE(
	[intInventoryReceiptItemId] INT NULL,
	[intInventoryReceiptChargeId] INT NULL,
	[intInventoryShipmentChargeId] INT NULL,
	[intSourceTransactionNoId] INT NULL,
	[strSourceTransactionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityVendorId] INT NULL,
	[intItemId] INT NOT NULL,
	[intToBillUOMId] INT NULL,
	[dblToBillQty] NUMERIC(38, 20) NULL DEFAULT((0)),
	[ysnStoreDebitMemo] BIT NULL
)