CREATE TABLE [dbo].[tblRestApiReceiptItemStaging]
(
      intRestApiReceiptItemStagingId INT IDENTITY(1, 1) NOT NULL
    , intRestApiReceiptStagingId INT NOT NULL
    , intItemId INT NOT NULL
    , dblReceiptQty NUMERIC(38, 20) NOT NULL
    , intReceiveUOMId INT NOT NULL
    , strOwnerShipType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, dblCost NUMERIC(38, 20) NULL
    , intCostUOMId INT NULL
    , dblUnitRetail NUMERIC(38, 20) NULL
    , intGrossUOMId INT NULL
    , dblGrossQty NUMERIC(38, 20) NULL
    , intStorageLocationId INT NULL
    , intStorageUnitId INT NULL
    , intTaxGroupId INT NULL
    , intForexRateType INT NULL
    , intTicketId INT NULL
    , intInventoryTransferId INT NULL
    , intInventoryTransferDetailId INT NULL
    , intPurchaseId INT NULL
    , intPurchaseDetailId INT NULL
    , intLoadShipmentId INT NULL
    , intLoadShipmentDetailId INT NULL
    , CONSTRAINT PK_tblRestApiReceiptItemStaging_intRestApiReceiptItemStagingId PRIMARY KEY(intRestApiReceiptItemStagingId)
    , CONSTRAINT [FK_tblRestApiReceiptStaging_tblRestApiReceiptItemStaging_intRestApiReceiptStagingId] 
        FOREIGN KEY ([intRestApiReceiptStagingId]) 
        REFERENCES [tblRestApiReceiptStaging]([intRestApiReceiptStagingId]) ON DELETE CASCADE
)