CREATE TABLE [dbo].[tblTRImportRackPriceDetail]
(
	[intImportRackPriceDetailId] INT NOT NULL IDENTITY, 
    [intImportRackPriceId] INT NOT NULL, 
	[intSupplyPointId] INT NOT NULL,
    [intItemId] INT NOT NULL, 
    [dblVendorPrice] INT NOT NULL, 
    [dtmEffectiveDate] DATETIME NOT NULL, 
	[strComments] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [ysnSuccess] BIT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblTRImportRackPriceDetail] PRIMARY KEY ([intImportRackPriceDetailId]), 
    CONSTRAINT [FK_tblTRImportRackPriceDetail_tblTRImportRackPrice] FOREIGN KEY ([intImportRackPriceId]) REFERENCES [tblTRImportRackPrice]([intImportRackPriceId]) ON DELETE CASCADE
)
