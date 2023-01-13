CREATE TYPE MFBatchSplitTableType AS TABLE
(
	intBatchId INT,
    intParentBatchId INT,
    intLocationId INT,
    intSplitStorageLocationId INT,
    intSplitStorageUnitId INT,
    dblSplitQuantity DECIMAL(18,6),
    dblSplitPackages DECIMAL(18,6) ,
    dblSplitWeightPerUnit DECIMAL(18,6),
    intSplitReasonCodeId INT,
    strSplitNotes NVARCHAR(MAX),
	dtmSplit DATETIME NULL,
	ysnSplit BIT
)