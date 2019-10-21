CREATE TABLE dbo.tblMFYieldDetail (
	intYieldDetailId INT IDENTITY(1, 1) NOT NULL
	,intYieldId INT NOT NULL
	,intYieldTransactionId INT NOT NULL
	,ysnSelect BIT NOT NULL
	,CONSTRAINT PK_tblMFYieldDetail_intYieldDetailId PRIMARY KEY (intYieldDetailId)
	,CONSTRAINT FK_tblMFYieldDetail_tblMFYield_intYieldId FOREIGN KEY (intYieldId) REFERENCES dbo.tblMFYield(intYieldId)
	,CONSTRAINT FK_tblMFYieldDetail_tblMFYieldTransaction_intYieldTransactionId FOREIGN KEY (intYieldTransactionId) REFERENCES dbo.tblMFYieldTransaction(intYieldTransactionId)
	)
