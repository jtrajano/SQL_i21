CREATE TABLE dbo.tblMFLotSnapshotDetail
	(
		intLotSnapshotDetail int IDENTITY,
		intLotSnapshotId int,
		intLotId					INT NOT NULL,
		intItemId					INT NOT NULL,
		intLocationId				INT NOT NULL,
		intItemUOMId				INT NOT NULL,			
		intSubLocationId			INT NULL,
		intStorageLocationId		INT NULL,
		dblQty					NUMERIC(38,20) DEFAULT ((0)) NOT NULL,		
		intLotStatusId			INT NOT NULL DEFAULT ((1)),
		intParentLotId			INT NULL,
		dblWeight					NUMERIC(38,20) NULL DEFAULT ((0)),
		intWeightUOMId			INT NULL,
		dblWeightPerQty			NUMERIC(38,20) NULL DEFAULT ((0)),
		intBondStatusId int null,
		CONSTRAINT PK_tblMFLotSnapshotDetail PRIMARY KEY CLUSTERED (intLotSnapshotDetail ASC),
		CONSTRAINT FK_tblMFLotSnapshotDetail_tblMFLotSnapshot FOREIGN KEY (intLotSnapshotId) REFERENCES tblMFLotSnapshot(intLotSnapshotId)
	)