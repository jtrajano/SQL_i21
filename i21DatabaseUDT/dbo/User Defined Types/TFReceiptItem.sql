CREATE TYPE [dbo].[TFReceiptItem] AS TABLE(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[intInventoryReceiptItemId] [int] NULL
)