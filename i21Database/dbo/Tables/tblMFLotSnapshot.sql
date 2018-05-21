CREATE TABLE dbo.tblMFLotSnapshot
(
	intLotSnapshotId int IDENTITY,
	dtmDate DATETIME NOT NULL,
	intCompanyId INT NULL,
	CONSTRAINT PK_tblMFLotSnapshot PRIMARY KEY CLUSTERED (intLotSnapshotId ASC)

)
