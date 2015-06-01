CREATE TABLE dbo.tblMFProductionSummary (
	intProductionSummaryId INT identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,intItemId INT NOT NULL
	,dblOpeningQuantity NUMERIC(18, 6)
	,dblInputQuantity NUMERIC(18, 6)
	,dblOutputQuantity NUMERIC(18, 6)
	,dblInputCountQuantity NUMERIC(18, 6)
	,dblOutputCountQuantity NUMERIC(18, 6)
	,dblYieldQuantity NUMERIC(18, 6)
	,dblYieldPercentage NUMERIC(18, 6)
	,CONSTRAINT PK_tblMFProductionSummary_intProductionSummaryId PRIMARY KEY (intProductionSummaryId)
	,CONSTRAINT FK_tblMFProductionSummary_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId)
	,CONSTRAINT FK_tblMFProductionSummary_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	)