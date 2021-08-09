CREATE TABLE [dbo].[tblARInventoryReceiptStaging](
	[intInventoryReceiptStagingId] [int] IDENTITY(1,1),
	[intInvoiceId] int,
	[strInvoiceNumber] [nvarchar](15),
	[intVendorId] int,
	[intCompanyLocationId] int,
	[strItemNo] [nvarchar](25),
	[dtmDate] [datetime],
	[dblExchangeRate] [numeric](38, 20),
	[dblQty] [numeric](38, 20),
	[dblCost] [numeric](38, 20),
	[strTaxGroup] [nvarchar](50),
	[strFreightTerm] [nvarchar](100),
    CONSTRAINT [PK_tblARInventoryReceiptStaging] PRIMARY KEY ([intInventoryReceiptStagingId]))