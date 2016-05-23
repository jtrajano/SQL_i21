CREATE TABLE [dbo].[tblTRImportRackPrice]
(
	[intImportRackPriceId] INT NOT NULL IDENTITY, 
    [dtmImportDate] DATETIME NOT NULL, 
    [strFilename] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnSuccess] BIT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblTRImportRackPrice] PRIMARY KEY ([intImportRackPriceId])
)
