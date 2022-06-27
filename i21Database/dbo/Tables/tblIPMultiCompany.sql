CREATE TABLE [dbo].[tblIPMultiCompany]
(
	[intMultiCompanyId] INT NOT NULL IDENTITY(1, 1),
	[intCompanyId] INT NOT NULL,
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnParent] BIT NOT NULL CONSTRAINT [DF_tblIPMultiCompany_ysnParent] DEFAULT 0,
	[intBookId] INT
	,strApprover nvarchar(100) COLLATE Latin1_General_CI_AS
	,ysnCurrentCompany BIT
	,strServerName nvarchar(max) COLLATE Latin1_General_CI_AS
	,strDatabaseName nvarchar(max) COLLATE Latin1_General_CI_AS
	,strUserName nvarchar(max) COLLATE Latin1_General_CI_AS
	,strPassword nvarchar(max) COLLATE Latin1_General_CI_AS
	,ysnPandSContractPositionSame Bit 
	,CONSTRAINT [PK_tblIPMultiCompany] PRIMARY KEY ([intMultiCompanyId])
)
