CREATE TABLE dbo.tblIPDemandStage (
	intDemandStageId int identity(1,1)
	,intTrxSequenceNo BIGINT
	,intActionId INT
	,dtmCreatedDate DATETIME
	,strCreatedBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strDemandName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intLineTrxSequenceNo BIGINT
	,strCompanyLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblQuantity NUMERIC(18, 6)
	,strQuantityUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dtmDemandDate DATETIME
	,intStatusId int
	)