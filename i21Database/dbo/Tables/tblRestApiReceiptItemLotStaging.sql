CREATE TABLE [dbo].[tblRestApiReceiptItemLotStaging] (
	  intRestApiReceiptItemLotStagingId INT IDENTITY(1, 1)
	, intRestApiReceiptItemStagingId INT NOT NULL
	, intLotId INT NULL
	, dblQuantity NUMERIC(38, 20)
	, dblGrossQty NUMERIC(38, 20) NULL
	, dblTareQty NUMERIC(38, 20) NULL
	, CONSTRAINT PK_tblRestApiReceiptItemLotStaging_intRestApiReceiptItemLotStagingId PRIMARY KEY(intRestApiReceiptItemLotStagingId)
    , CONSTRAINT [FK_tblRestApiReceiptItemLotStaging_tblRestApiReceiptItemStaging_intRestApiReceiptItemStagingId] 
        FOREIGN KEY ([intRestApiReceiptItemStagingId]) 
        REFERENCES [tblRestApiReceiptItemStaging]([intRestApiReceiptItemStagingId]) ON DELETE CASCADE
)