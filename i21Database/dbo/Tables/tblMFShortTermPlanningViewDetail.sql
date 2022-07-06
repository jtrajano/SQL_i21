
CREATE TABLE tblMFShortTermPlanningViewDetail (
	intContractDetailId INT
	,intLoadContainerId INT
	,intItemId INT
	,intLocationId INT
	,intAttributeId INT
	,intUserId INT
	,dtmDate DATETIME
	,dblBalanceMonthForecast NUMERIC(18, 0)
	,dblNextMonthForecast NUMERIC(18, 0)
	,dblDOH NUMERIC(18, 0)
	,strContainerNumber NVARCHAR(50) Collate Latin1_General_CI_AS
	,strMarks NVARCHAR(50) Collate Latin1_General_CI_AS
	,dblQty NUMERIC(18, 0)
	,strQtyUOM NVARCHAR(50) Collate Latin1_General_CI_AS
	,dblWeight NUMERIC(18, 0)
	,strWeightUOM NVARCHAR(50) Collate Latin1_General_CI_AS
	,intSubLocationId INT
	)
