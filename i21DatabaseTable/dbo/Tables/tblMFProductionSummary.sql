CREATE TABLE dbo.tblMFProductionSummary (
	intProductionSummaryId INT identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,intItemId INT NOT NULL
	,intCategoryId INT NULL
	,intItemTypeId INT NULL 
	,dblOpeningQuantity NUMERIC(18, 6)
	,dblOpeningOutputQuantity NUMERIC(18, 6)
	,dblOpeningConversionQuantity NUMERIC(18, 6)
	,dblInputQuantity NUMERIC(18, 6)
	,dblConsumedQuantity NUMERIC(18, 6)
	,dblOutputQuantity NUMERIC(18, 6)
	,dblOutputConversionQuantity NUMERIC(18, 6)
	,dblCountQuantity NUMERIC(18, 6)
	,dblCountOutputQuantity NUMERIC(18, 6)
	,dblCountConversionQuantity NUMERIC(18, 6)
	,dblCalculatedQuantity NUMERIC(18, 6)
	,dblYieldQuantity NUMERIC(18, 6)
	,dblYieldPercentage NUMERIC(18, 6)
	,intCreatedUserId int NULL
	,dtmCreated datetime NULL CONSTRAINT DF_tblMFProductionSummary_dtmCreated DEFAULT GetDate()
	,intConcurrencyId INT NULL CONSTRAINT DF_tblMFProductionSummary_intConcurrencyId DEFAULT 0 
	,dblRequiredQty NUMERIC(18, 6) NULL
	,intMachineId int
	,intStageLocationId int
	,dblDirectCost Numeric(38,20)
	,intDirectCostId int
	,dblIndirectCost Numeric(38,20)
	,intIndirectCostId int
	,dblMarketRate NUMERIC(38,20)
	,intMarketRateId int
	,intMarketRatePerUnitId int
	,dblGradeDiff NUMERIC(38,20)
	,dblCoEfficient Numeric(38,20)
	,dblCoEfficientApplied Numeric(38,20)
	,dblStandardUnitRate Numeric(38,20)
	,dblProductionUnitRate Numeric(38,20)
	,dblCost Numeric(38,20)
	,ysnZeroCost BIT
    ,CONSTRAINT PK_tblMFProductionSummary_intProductionSummaryId PRIMARY KEY (intProductionSummaryId)
	,CONSTRAINT FK_tblMFProductionSummary_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId) ON DELETE CASCADE
	,CONSTRAINT FK_tblMFProductionSummary_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	)
