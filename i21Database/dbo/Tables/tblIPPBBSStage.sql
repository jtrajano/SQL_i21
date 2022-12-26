CREATE TABLE tblIPPBBSStage (
	intPBBSStageId INT IDENTITY(1, 1)
	,intDocNo BIGINT
	,strSender NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intPBBSID INT
	,strBlendCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMaterialCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmValidFrom DATETIME
	,dtmValidTo DATETIME
	,dblSieve1M NUMERIC(18, 6)
	,dblSieve1T1 NUMERIC(18, 6)
	,dblSieve1T2 NUMERIC(18, 6)
	,strPDFFileName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,blbPDFContent VARBINARY (MAX)
	
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,dtmTransactionDate DATETIME DEFAULT(GETDATE())
	,ysnMailSent BIT DEFAULT 0
	,intStatusId INT
	
	,CONSTRAINT PK_tblIPPBBSStage PRIMARY KEY (intPBBSStageId)
	)
