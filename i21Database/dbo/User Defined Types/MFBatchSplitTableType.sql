CREATE  TYPE MFBatchSplitTableType AS TABLE
(
	intBatchId INT,
    intParentBatchId INT,
    intSplitStorageLocationId INT,
    intSplitStorageUnitId INT,
    intSplitPackageUOMId INT,
    dblSplitQuantity DECIMAL(18,6),
    dblSplitPackages DECIMAL(18,6) ,
    dblSplitWeightPerUnit DECIMAL(18,6),
    intSplitReasonCodeId INT,
    strSplitNotes NVARCHAR(MAX),
	dtmSplitChild DATETIME NULL,
	ysnSplit BIT
)

