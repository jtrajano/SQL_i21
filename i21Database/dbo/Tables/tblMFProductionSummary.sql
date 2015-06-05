CREATE TABLE dbo.tblMFProductionSummary (
	intProductionSummaryId INT identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,intItemId INT NOT NULL
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
	,CONSTRAINT PK_tblMFProductionSummary_intProductionSummaryId PRIMARY KEY (intProductionSummaryId)
	,CONSTRAINT FK_tblMFProductionSummary_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId)
	,CONSTRAINT FK_tblMFProductionSummary_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	)
