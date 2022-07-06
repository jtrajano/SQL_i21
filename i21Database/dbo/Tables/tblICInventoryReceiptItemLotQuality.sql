CREATE TABLE [dbo].[tblICInventoryReceiptItemLotQuality]
(
	[intInventoryReceiptItemLotQualityId] INT NOT NULL IDENTITY, 
	[intInventoryReceiptItemLotId] INT NOT NULL,
	[intComponentMapId] INT NULL,
	[strValue] NVARCHAR(200) NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL, 		
	CONSTRAINT [PK_tblICInventoryReceiptItemLotQuality] PRIMARY KEY ([intInventoryReceiptItemLotQualityId]), 
	CONSTRAINT [FK_tblICInventoryReceiptItemLotQuality_tblICInventoryReceiptItemLot] FOREIGN KEY ([intInventoryReceiptItemLotId]) REFERENCES [tblICInventoryReceiptItemLot]([intInventoryReceiptItemLotId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICInventoryReceiptItemLotQuality_tblQMComponentMap] FOREIGN KEY ([intComponentMapId]) REFERENCES tblQMComponentMap([intComponentMapId]), 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptItemLotQuality_intInventoryReceiptItemLotId]
	ON [dbo].[tblICInventoryReceiptItemLotQuality]([intInventoryReceiptItemLotId] ASC)

GO
