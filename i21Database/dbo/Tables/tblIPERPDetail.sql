CREATE TABLE [dbo].[tblIPERPDetail]
(
	intERPDetailId INT NOT NULL IDENTITY(1, 1)
	,strServerName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strDatabaseName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strCuppingPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strGradingPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS

	,CONSTRAINT [PK_tblIPERPDetail] PRIMARY KEY (intERPDetailId)
)
