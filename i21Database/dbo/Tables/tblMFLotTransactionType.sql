CREATE TABLE tblMFLotTransactionType (
	intTransactionTypeId INT NOT NULL
	,ysnUndoneAllowed BIT NOT NULL
	,ysnApplyTransactionByParentLot BIT
	,CONSTRAINT PK_tblMFLotTransactionType_intTransactionTypeId PRIMARY KEY (intTransactionTypeId)
	)