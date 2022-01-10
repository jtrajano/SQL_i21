CREATE TABLE [dbo].[tblICImportStagingReceiptItemLotQuality]
(
    [intImportStagingReceiptItemLotQualityId] INT IDENTITY(1, 1) NOT NULL,
    [strImportIdentifier] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intInventoryReceiptItemLotId] INT NOT NULL,
    [strComponent] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	[intConcurrencyId] INT NULL,
    CONSTRAINT [PK_tblICImportStagingReceiptItemLotQuality] PRIMARY KEY ([intImportStagingReceiptItemLotQualityId] ASC)
)