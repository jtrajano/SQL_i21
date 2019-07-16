CREATE TABLE tblGRTransferStorageReference
(
	intTransferStorageReferenceId INT NOT NULL IDENTITY(1,1),
	intSourceCustomerStorageId INT NOT NULL,
	intToCustomerStorageId INT NOT NULL,
	intTransferStorageSplitId INT NOT NULL,
	intTransferStorageId INT NOT NULL,
	dblUnitQty NUMERIC(38,20) NOT NULL DEFAULT(0),
	dblSplitPercent NUMERIC(38,20) NOT NULL DEFAULT(0),
	dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE())
)
