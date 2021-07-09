CREATE TABLE tblICTransactionLinks (
	intTransactionLinkId INT NOT NULL IDENTITY(1, 1),
	guiTransactionGraphId UNIQUEIDENTIFIER NOT NULL,
	intSrcId INT NULL,
	strSrcTransactionNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	strSrcTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSrcModuleName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intDestId INT NULL,
	strDestTransactionNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	strDestTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strDestModuleName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strOperation NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	dtmLinkUtcDate DATETIME NOT NULL,
	CONSTRAINT tblICTransactionLinks_intTransactionLinkId
		PRIMARY KEY (intTransactionLinkId)
)

GO