CREATE TABLE dbo.tblApiInventoryTransferStaging
(
	intApiInventoryTransferStagingId INT NOT NULL IDENTITY(1, 1),
	guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
	dtmTransferDate DATETIME NOT NULL,
	intFromLocationId INT NOT NULL,
	intToLocationId INT NOT NULL,
	strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	intStatusId INT NOT NULL,
	ysnShipmentRequired BIT NULL,
	intShipViaId INT NULL,
	strBOLNumber NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	intBrokerId INT NULL,
	dtmBOLDate DATETIME NULL,
	dtmBOLReceiveDate DATETIME NULL,
	CONSTRAINT PK_tblApiInventoryTransferStaging_intApiInventoryTransferStagingId PRIMARY KEY (intApiInventoryTransferStagingId)
)