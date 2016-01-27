CREATE TABLE dbo.tblMFYieldTransaction (
	intYieldTransactionId INT NOT NULL
	,strYieldTransactionName NVARCHAR(50) NOT NULL
	,ysnProcessRelated BIT NOT NULL
	,ysnInputTransaction BIT NOT NULL
	,CONSTRAINT PK_tblMFYieldTransaction_intYieldTransactionId PRIMARY KEY (intYieldTransactionId)
	,CONSTRAINT UQ_tblMFYieldTransaction_strYieldTransactionName UNIQUE (strYieldTransactionName)
	)
