CREATE TABLE tblICItemStage (
	intItemStageId INT identity(1, 1) CONSTRAINT PK_tblICItemStage_intItemStageId PRIMARY KEY
	,intItemId INT
	,strItemXML NVARCHAR(MAX)
	,strRowState NVARCHAR(50)
	,strUserName NVARCHAR(50)
	,intMultiCompanyId INT
	,strFeedStatus NVARCHAR(50)
	,strMessage NVARCHAR(MAX)
	)
