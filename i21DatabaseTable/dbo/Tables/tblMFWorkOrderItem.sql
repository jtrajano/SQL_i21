CREATE TABLE dbo.tblMFWorkOrderItem (
	intWorkOrderItemId INT identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,intItemId INT NOT NULL
	,ysnInputItem INT NOT NULL
	,dblCalculatedQuantity NUMERIC(18, 6) NOT NULL
	,dblShrinkage NUMERIC(18, 6) NOT NULL
	,intItemUOMId INT NOT NULL
	,dblCalculatedUpperTolerance NUMERIC(18, 6) NOT NULL
	,dblCalculatedLowerTolerance NUMERIC(18, 6) NOT NULL
	,ysnScaled BIT NOT NULL
	,dblConsumedQty NUMERIC(18, 6) NULL
	,CONSTRAINT PK_tblMFWorkOrderItem_intWorkOrderItemId PRIMARY KEY (intWorkOrderItemId)
	,CONSTRAINT FK_tblMFWorkOrderItem_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId)
	,CONSTRAINT FK_tblMFWorkOrderItem_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES dbo.tblICItem(intItemId)
	,CONSTRAINT FK_tblMFWorkOrderItem_tblICItemUOM_intItemUOMId FOREIGN KEY (intItemUOMId) REFERENCES dbo.tblICItemUOM(intItemUOMId)
	,CONSTRAINT FK_tblMFWorkOrderItem_intWorkOrderId_intItemId_ysnInputItem UNIQUE NONCLUSTERED (
		intWorkOrderItemId
		,intItemId
		)
	)
