CREATE TABLE [dbo].[tblMFLotInventory]
(
	[intLotInventoryId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFLotInventory_intConcurrencyId] DEFAULT 0, 
	[intLotId] INT NOT NULL, 
	[intItemOwnerId] INT, 
	intBondStatusId int,
	strVendorRefNo nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strWarehouseRefNo nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,strReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL
	,dtmReceiptDate datetime NOT NULL DEFAULT (getdate())
	CONSTRAINT [PK_tblMFLotInventory] PRIMARY KEY ([intLotInventoryId]), 
	CONSTRAINT [AK_tblMFLotInventory_intLotId] UNIQUE ([intLotId]), 
	CONSTRAINT [FK_tblMFLotInventory_tblICLot] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFLotInventory_tblICItemOwner] FOREIGN KEY ([intItemOwnerId]) REFERENCES [tblICItemOwner]([intItemOwnerId])
)