CREATE TABLE [dbo].[tblTRImportRackPriceDetail]
(
	[intImportRackPriceDetailId] INT NOT NULL IDENTITY, 
    [intImportRackPriceId] INT NOT NULL, 
	[strSupplyPoint] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSupplyPointId] INT NULL,
    [dtmEffectiveDate] DATETIME NOT NULL, 
	[strComments] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[ysnSelected] BIT NULL DEFAULT ((1)),
	[ysnValid] BIT NULL DEFAULT((1)),
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblTRImportRackPriceDetail] PRIMARY KEY ([intImportRackPriceDetailId]), 
    CONSTRAINT [FK_tblTRImportRackPriceDetail_tblTRImportRackPrice] FOREIGN KEY ([intImportRackPriceId]) REFERENCES [tblTRImportRackPrice]([intImportRackPriceId]) ON DELETE CASCADE
)