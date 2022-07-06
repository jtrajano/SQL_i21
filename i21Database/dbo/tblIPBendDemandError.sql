CREATE TABLE dbo.tblIPBendDemandError (
	intBendDemandErrorId int identity(1,1)
	,intTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(6) COLLATE Latin1_General_CI_AS
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDemandType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItem NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strWorkCenter NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmDueDate DATETIME
	,strMachine NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,ysnMailSent BIT 
	,intLineTrxSequenceNo BIGINT
	)