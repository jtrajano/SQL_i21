CREATE TABLE [dbo].[tblARInventoryReceipt]
(
	[intInventoryReceiptId] [int] IDENTITY(1,1) NOT NULL,
	[intInvoiceId] int NOT NULL,
	[strInvoiceNumber] [nvarchar](15) NOT NULL,
	[strReceiptNumber] [nvarchar](15) NOT NULL,
	[ysnDeleted] [bit] NOT NULL default 0, 
    CONSTRAINT [PK_tblARInventoryReceipt] PRIMARY KEY ([intInventoryReceiptId])
)
