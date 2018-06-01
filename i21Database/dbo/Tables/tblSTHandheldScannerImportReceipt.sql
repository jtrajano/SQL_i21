CREATE TABLE [dbo].[tblSTHandheldScannerImportReceipt]
(
	[intHandheldScannerImportReceiptId] INT NOT NULL IDENTITY, 
    [intHandheldScannerId] INT NOT NULL, 
    [strVendorComment] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intVendorId] INT NULL, 
    [strReceiptSequence] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strUPCNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmReceiptDate] DATETIME NULL, 
    [dblReceivedQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblCaseCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblUnitRetail] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strCostChange] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strRetailChange] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblSTHandheldScannerImportReceipt] PRIMARY KEY ([intHandheldScannerImportReceiptId]), 
    CONSTRAINT [FK_tblSTHandheldScannerImportReceipt_tblSTHandheldScanner] FOREIGN KEY ([intHandheldScannerId]) REFERENCES [tblSTHandheldScanner]([intHandheldScannerId]) ON DELETE CASCADE
)
