CREATE TABLE dbo.tblMFWorkOrderWarehouseRateMatrixDetail
(
intWorkOrderWarehouseRateMatrixDetailId int NOT NULL IDENTITY(1,1)
,intWorkOrderId int
,intWarehouseRateMatrixDetailId int
,dblQuantity numeric(18,6)
,dblProcessedQty numeric(18,6)
,dblEstimatedAmount numeric(18,6)
,dblActualAmount numeric(18,6)
,dblDifference numeric(18,6)
,[dtmCreated] DATETIME NULL
,[intCreatedUserId] INT NULL
,[dtmLastModified] DATETIME NULL 
,[intLastModifiedUserId] INT NULL
,intBillId int
,strERPServicePOLineNo nvarchar(50) COLLATE Latin1_General_CI_AS
,[intConcurrencyId] INT CONSTRAINT [DF_tblMFWorkOrderWarehouseRateMatrixDetail_intConcurrencyId] DEFAULT 0

,CONSTRAINT [PK_tblMFWorkOrderWarehouseRateMatrixDetail_intWorkOrderWarehouseRateMatrixDetailId] PRIMARY KEY (intWorkOrderWarehouseRateMatrixDetailId)
,CONSTRAINT [FK_tblMFWorkOrderWarehouseRateMatrixDetail_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY (intWorkOrderId) REFERENCES tblMFWorkOrder(intWorkOrderId) ON DELETE CASCADE
,CONSTRAINT [FK_tblMFWorkOrderWarehouseRateMatrixDetail_tblLGWarehouseRateMatrixDetail_intWarehouseRateMatrixDetailId] FOREIGN KEY (intWarehouseRateMatrixDetailId) REFERENCES tblLGWarehouseRateMatrixDetail(intWarehouseRateMatrixDetailId)
)
