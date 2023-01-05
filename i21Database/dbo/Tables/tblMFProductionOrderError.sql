
CREATE TABLE tblMFProductionOrderError (
	intProductionOrderArchiveId INT	identity(1,1)
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
	,dtmFeedDate DateTime 
	,strMessage nvarchar(MAX) collate Latin1_General_CI_AS
	)
