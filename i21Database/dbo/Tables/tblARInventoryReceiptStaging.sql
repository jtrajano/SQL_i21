CREATE TABLE [dbo].[tblARInventoryReceiptStaging](
	[intInventoryReceiptStagingId] [int] IDENTITY(1,1) NOT NULL,
	[intInvoiceId] int NOT NULL,
	[strInvoiceNumber] [nvarchar](15) NOT NULL,
	[intVendorId] int NOT NULL,
	[intCompanyLocationId] int NOT NULL,
	[strItemNo] [nvarchar](25) NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[dblExchangeRate] [numeric](38, 20) NOT NULL,
	[dblQty] [numeric](38, 20) NOT NULL,
	[dblCost] [numeric](38, 20) NOT NULL,
	[intTaxGroupId] int,
	[ysnProcessed] [bit] NULL, 
    CONSTRAINT [PK_tblARInventoryReceiptStaging] PRIMARY KEY ([intInventoryReceiptStagingId]))