CREATE TABLE dbo.tblApiInventoryTransferDetailStaging
(
	intApiInventoryTransferDetailStagingId INT NOT NULL IDENTITY(1, 1),
	intApiInventoryTransferStagingId INT NOT NULL,
	intItemId INT NULL,
	intItemUOMId INT NULL,
	strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	intUOMId INT NULL,
	intOwnershipType INT NULL DEFAULT(1),
	dblTransferQty NUMERIC(38, 20) NULL,
	intFromStorageLocationId INT NULL,
	intToStorageLocationId INT NULL,
	intFromStorageUnitId INT NULL,
	intToStorageUnitId INT NULL,
	intLotId INT NULL,
	strNewLotNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	ysnWeighed BIT NULL,
	intGrossUOMId INT NULL,
	dblGross NUMERIC(38, 20) NULL,
	dblTare NUMERIC(38, 20) NULL,
	dblStandardWeight NUMERIC(38, 20) NULL,
	strNewLotStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strLotCondition NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strComment NVARCHAR(2000) COLLATE Latin1_General_CI_AS NULL,	
	CONSTRAINT PK_tblApiInventoryTransferDetailStaging_intApiInventoryTransferDetailStagingId PRIMARY KEY (intApiInventoryTransferDetailStagingId),
	CONSTRAINT FK_tblApiInventoryTransferDetailStaging_intApiInventoryTransferStagingId FOREIGN KEY (intApiInventoryTransferStagingId) 
		REFERENCES tblApiInventoryTransferStaging (intApiInventoryTransferStagingId) ON DELETE CASCADE
)