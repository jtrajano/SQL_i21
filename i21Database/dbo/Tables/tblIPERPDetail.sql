CREATE TABLE [dbo].[tblIPERPDetail]
(
	intERPDetailId INT NOT NULL IDENTITY(1, 1)
	,strServerName NVARCHAR(MAX)
	,strDatabaseName NVARCHAR(MAX)
	,strCuppingPropertyName NVARCHAR(100)
	,strGradingPropertyName NVARCHAR(100)

	,CONSTRAINT [PK_tblIPERPDetail] PRIMARY KEY (intERPDetailId)
)
