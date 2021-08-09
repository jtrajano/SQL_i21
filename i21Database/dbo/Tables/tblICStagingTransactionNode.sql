CREATE TABLE tblICStagingTransactionNode (
	intStagingTransactionNodeId INT IDENTITY(1, 1) NOT NULL,
	guiIdentifier UNIQUEIDENTIFIER NOT NULL, 
	intTransactionId INT NOT NULL, 
	strTransactionNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	strModuleName NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT tblICStagingTransactionNode_intStagingTransactionNodeId PRIMARY KEY (intStagingTransactionNodeId))

GO