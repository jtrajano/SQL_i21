CREATE TABLE dbo.tblMFItemDemand (
	intItemDemandId INT identity(1, 1) CONSTRAINT PK_tblMFItemDemand_intItemDemandId PRIMARY KEY
	,intItemId INT NOT NULL
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intLocationId INT NOT NULL
	,strWarehouseName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strMaint NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblHoldQty NUMERIC(18, 6)
	,dblOnHand NUMERIC(18, 6)
	,dblOnOrderQty NUMERIC(18, 6)
	,dblTOUT NUMERIC(18, 6)
	,dblTIN NUMERIC(18, 6)
	,dblAvail NUMERIC(18, 6)
	,dblMtdShip NUMERIC(18, 6)
	,dblRollingcs NUMERIC(18, 6)
	,dblFcst1 NUMERIC(18, 6)
	,dblFcst2 NUMERIC(18, 6)
	,dblfcst3 NUMERIC(18, 6)
	,dblTotalProd NUMERIC(18, 6)
	,dblReorderPoint NUMERIC(18, 6)
	,intCompanyId INT NULL
	)