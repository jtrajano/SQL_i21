CREATE TABLE [dbo].[tblTRImportRackPriceDetailItem]
(
	[intImportRackPriceDetailItemId] INT NOT NULL IDENTITY, 
    [intImportRackPriceDetailId] INT NOT NULL, 
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intItemId] INT NOT NULL, 
    [dblVendorPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblJobberPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strEquation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblTRImportRackPriceDetailItem] PRIMARY KEY ([intImportRackPriceDetailItemId]), 
    CONSTRAINT [FK_tblTRImportRackPriceDetailItem_tblTRImportRackPriceDetail] FOREIGN KEY ([intImportRackPriceDetailId]) REFERENCES [tblTRImportRackPriceDetail]([intImportRackPriceDetailId]) ON DELETE CASCADE
)
