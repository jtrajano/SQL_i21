CREATE TABLE tblMFProductionOrderStage (
	intProductionOrderStageId INT identity(1,1)
	,intDocNo BigInt
	,strOrderNo NVARCHAR(50) collate Latin1_General_CI_AS
	,strLocationCode NVARCHAR(50) collate Latin1_General_CI_AS
	,dblOrderQuantity numeric(18,6)
	,strOrderQuantityUOM NVARCHAR(50) collate Latin1_General_CI_AS
	,dblNoOfMixes numeric(18,6)
	,dtmPlanDate DateTime
	,strBatchId NVARCHAR(50) collate Latin1_General_CI_AS
	,dblNoOfPack NUMERIC(18, 6)
	,strNoOfPackUOM NVARCHAR(50) collate Latin1_General_CI_AS
	,dblWeight NUMERIC(18, 6)
	,strWeightUOM NVARCHAR(50) collate Latin1_General_CI_AS
	,dtmFeedDate DateTime Default GETDATE()
	,intStatusId int
	,dblTeaTaste NUMERIC(18, 6)
	,dblTeaHue NUMERIC(18, 6)
	,dblTeaIntensity NUMERIC(18, 6)
	,dblTeaMouthFeel NUMERIC(18, 6)
	,dblTeaAppearance NUMERIC(18, 6)
	,dblTeaVolume NUMERIC(18, 6)
	,strSessionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ''
)