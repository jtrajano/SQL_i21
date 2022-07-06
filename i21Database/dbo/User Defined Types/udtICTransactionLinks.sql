CREATE TYPE [dbo].[udtICTransactionLinks] AS TABLE
(
	
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intSrcId INT NOT NULL,
	strSrcTransactionNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	strSrcTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strSrcModuleName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	intDestId INT NULL,
	strDestTransactionNo NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	strDestTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strDestModuleName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	strOperation NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL
)

GO