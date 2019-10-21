CREATE TYPE [dbo].[TFReceiptTransaction] AS TABLE(
	[intId] [int] NULL,
	[intInventoryReceiptItemId] [int] NULL,
	[strBillOfLading] [nvarchar](max) NULL
)