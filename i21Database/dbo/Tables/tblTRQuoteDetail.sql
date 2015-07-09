CREATE TABLE [dbo].[tblTRQuoteDetail]
(
	[intQuoteDetailId] INT NOT NULL IDENTITY,
	[intQuoteHeaderId] INT NOT NULL,
	[intItemId] INT NOT NULL,
	[intTerminalId] INT NOT NULL,
	[intSupplyPointId] INT NOT NULL,
	[dblRackPrice] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblDeviationAmount] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblTempAdjustment] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblQuotePrice] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblMargin] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblQtyOrdered]  NUMERIC (18, 6) NULL  DEFAULT 0,
	[dblExtProfit] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblTax] DECIMAL(18, 6) NULL DEFAULT 0, 	
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRQuoteDetail] PRIMARY KEY ([intQuoteDetailId]),	
	CONSTRAINT [FK_tblTRQuoteDetail_tblTRQuoteHeader_intQuoteHeaderId] FOREIGN KEY ([intQuoteHeaderId]) REFERENCES [dbo].[tblTRQuoteHeader] ([intQuoteHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRQuoteDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblTRQuoteDetail_tblAPVendor_intTerminalId] FOREIGN KEY ([intTerminalId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]),
    CONSTRAINT [FK_tblTRQuoteDetail_tblTRSupplyPoint_intSupplyPointId] FOREIGN KEY ([intSupplyPointId]) REFERENCES [dbo].[tblTRSupplyPoint] ([intSupplyPointId])
)
