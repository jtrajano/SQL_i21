CREATE TABLE [dbo].[tblTRRackPriceDetail]
(
	[intRackPriceDetailId] INT NOT NULL IDENTITY,
	[intRackPriceHeaderId] INT NOT NULL,
	[intItemId] INT NOT NULL,	
	[dblVendorRack] DECIMAL(18, 6) NULL DEFAULT((0)), 
	[dblJobberRack] DECIMAL(18, 6) NULL DEFAULT((0)), 
	[intConcurrencyId] INT NULL DEFAULT((0)),
	CONSTRAINT [PK_tblTRRackPriceDetail] PRIMARY KEY ([intRackPriceDetailId]),
	CONSTRAINT [FK_tblTRRackPriceDetail_tblTRRackPriceHeader_intRackPriceHeaderId] FOREIGN KEY ([intRackPriceHeaderId]) REFERENCES [dbo].[tblTRRackPriceHeader] ([intRackPriceHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRRackPriceDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]), 
    CONSTRAINT [AK_tblTRRackPriceDetail_intItemId] UNIQUE ([intRackPriceHeaderId], [intItemId])	
)
