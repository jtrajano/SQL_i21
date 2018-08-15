CREATE TABLE dbo.tblMFWorkOrderProducedLotTransaction (
	intWorkOrderProducedLotTransactionId INT IDENTITY(1, 1) NOT NULL
	,intWorkOrderId INT NULL
	,intLotId INT NULL
	,dblQuantity DECIMAL(24, 10) NULL
	,intItemUOMId INT NULL
	,intItemId INT NULL
	,intTransactionId INT NULL
	,intTransactionTypeId INT NULL
	,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dtmTransactionDate DATETIME NULL
	,intProcessId INT NULL
	,intShiftId INT NULL
	,intBatchId int
	,intStorageLocationId int
	,intSubLocationId int
	,CONSTRAINT PK_tblMFWorkOrderProducedLotTransaction_intWorkOrderProducedLotTransactionId PRIMARY KEY (intWorkOrderProducedLotTransactionId)
	)