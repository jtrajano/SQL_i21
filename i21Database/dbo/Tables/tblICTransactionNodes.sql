CREATE TABLE tblICTransactionNodes (
	intTransactionNodeId INT NOT NULL IDENTITY(1, 1),
	guiTransactionGraphId UNIQUEIDENTIFIER NOT NULL,
	intTransactionId INT NOT NULL,
	strTransactionNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strModuleName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT tblICTransactionNodes_intTransactionNodeId
		PRIMARY KEY (intTransactionNodeId)
)

GO

CREATE NONCLUSTERED INDEX [IX_tblICTransactionNodes]
	ON [dbo].[tblICTransactionNodes](intTransactionId ASC, strTransactionNo ASC, strTransactionType ASC, strModuleName ASC)
GO