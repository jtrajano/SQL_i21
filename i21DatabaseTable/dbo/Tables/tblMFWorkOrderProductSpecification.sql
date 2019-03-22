CREATE TABLE dbo.tblMFWorkOrderProductSpecification (
	intWorkOrderProductSpecificationId INT identity(1, 1)
	,intWorkOrderId INT NOT NULL
	,strParameterName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strParameterValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
	,intConcurrencyId INT NULL 
	,CONSTRAINT FK_tblMFWorkOrderProductSpecification_intWorkOrderProductSpecificationId PRIMARY KEY (intWorkOrderProductSpecificationId)
	,CONSTRAINT FK_tblMFWorkOrderProductSpecification_tblMFWorkOrder_intWorkOrderId FOREIGN KEY (intWorkOrderId) REFERENCES dbo.tblMFWorkOrder(intWorkOrderId)
	)