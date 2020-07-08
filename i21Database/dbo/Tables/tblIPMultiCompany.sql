CREATE TABLE [dbo].[tblIPMultiCompany]
(
	[intMultiCompanyId] INT NOT NULL IDENTITY(1, 1),
	[intCompanyId] INT NOT NULL,
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnParent] BIT NOT NULL CONSTRAINT [DF_tblIPMultiCompany_ysnParent] DEFAULT 0,
	[intBookId] INT
	,strApprover nvarchar(100) COLLATE Latin1_General_CI_AS
	,ysnCurrentCompany BIT
	,strServerName nvarchar(max)
	,strDatabaseName nvarchar(max)
	,strUserName nvarchar(max)
	,strPassword nvarchar(max)
	,CONSTRAINT [PK_tblIPMultiCompany] PRIMARY KEY ([intMultiCompanyId])
)
