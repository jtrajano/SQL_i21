CREATE TABLE [dbo].[tblARInventoryReceiptLog]
(
	[intInventoryReceiptLogId] [int] IDENTITY(1,1) NOT NULL,
	[strInvoiceNumber] [nvarchar](15) NOT NULL,
	[intInventoryReceiptId] int NOT NULL,
	[strReceiptNumber] [nvarchar](15) NOT NULL,
	[ysnDeleted] [bit] NOT NULL default 0, 
    CONSTRAINT [PK_tblARInventoryReceiptLog] PRIMARY KEY ([intInventoryReceiptLogId])
)
