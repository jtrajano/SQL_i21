CREATE TABLE [dbo].[tblSTHandheldScannerExportPricebook]
(
	[intHandheldScannerExportPricebookId] INT NOT NULL IDENTITY, 
    [intHandheldScannerId] INT NOT NULL, 
    [strUPCNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strCaseUPC] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strPOSDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intCaseSize] INT NULL,
	[dblLastCaseCost] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblUnitPrice] NUMERIC (18, 6) NULL DEFAULT ((0)),
	[strItemUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strVendorId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDeptNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblOnHandQty] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblSTHandheldScannerExportPricebook] PRIMARY KEY ([intHandheldScannerExportPricebookId]), 
    CONSTRAINT [FK_tblSTHandheldScannerExportPricebook_tblSTHandheldScanner] FOREIGN KEY ([intHandheldScannerId]) REFERENCES [tblSTHandheldScanner]([intHandheldScannerId]) ON DELETE CASCADE 
)
