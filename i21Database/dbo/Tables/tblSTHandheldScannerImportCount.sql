CREATE TABLE [dbo].[tblSTHandheldScannerImportCount]
(
	[intHandheldScannerImportCountId] INT NOT NULL IDENTITY, 
    [intHandheldScannerId] INT NOT NULL, 
    [strUPCNo] NVARCHAR(50) NULL, 
    [dblCountQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblSTHandheldScannerImportCount] PRIMARY KEY ([intHandheldScannerImportCountId]), 
    CONSTRAINT [FK_tblSTHandheldScannerImportCount_tblSTHandheldScanner] FOREIGN KEY ([intHandheldScannerId]) REFERENCES [tblSTHandheldScanner]([intHandheldScannerId]) ON DELETE CASCADE
)
