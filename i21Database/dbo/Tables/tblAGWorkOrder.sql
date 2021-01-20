﻿CREATE TABLE [dbo].[tblAGWorkOrder]
(
 [intWorkOrderId] INT IDENTITY (1, 1) NOT NULL,
 [strType] NVARCHAR(20) NULL,
 [intCompanyLocationId] INT NULL,
 [strStatus] NVARCHAR(10) NULL,
 [strOrderNumber] NVARCHAR(250) NULL,
 [intEntityCustomerId] INT NULL,
 [strCustomerName] NVARCHAR(500) COLLATE Latin1_General_CI_AS  NULL,
 [dtmApplyDate] DATETIME NULL,
 [intApplicatorId] INT NULL,
 [strApplicatorLicenseNumber]  NVARCHAR(MAX) NULL,
 [intOrderedById] INT NULL,
 [intFarmFieldId] INT NULL,
 [intTermId] INT NULL,
 [intItemId] INT NULL,
 [intEntityId] INT NOT NULL,
 [intApplicationTargetId] INT NULL, --new table application targets
 [intEntitySalesRepId] INT NULL, 
 [intSplitId] INT NULL, 
 [dblAcres] NUMERIC(18,6) NULL,
 [strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
 [strFarmDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
 [strFieldDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
 [strOrderStatus] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
 [dblRatePerAcre] DECIMAL(18,6) NULL,
 [dblBatchSize] DECIMAL(18,6) NULL,
 [dblTotalGallonsOfSolutions] DECIMAL(18,6) NULL,
 [dblTotalPoundsOfProduct] DECIMAL(18,6) NULL,
 [dblDensity] DECIMAL(18,6) NULL,
 [dtmStartDate] DATETIME NULL,
 [dtmEndDate] DATETIME NULL,
 [dtmStartTime] DATETIME NULL,
 [dblAppliedAcres] NUMERIC(18,6) NULL,
 [dblApplicationRate] NUMERIC (18,6) NULL,
 [dblSalesOrderSubtotal] NUMERIC(18,6) NULL,
 [dblShipping] NUMERIC(18,6) NULL,
 [dblTax] NUMERIC(18,6) NULL,
 [dblTotalDiscount] NUMERIC(18,6) NULL,
 [dblSalesOrderTotal] NUMERIC(18,6) NULL,
 [strSeason] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
 [strWindDirection] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
 [dblWindSpeed] NUMERIC(18,6) NULL,
 [strWindSpeedUOM] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
 [strSoilCondition] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
 [dblTemperature] NUMERIC(18,6) NULL,
 [strTemperatureUOM] CHAR(1) NULL,
 [blbApplicatorSignature] VARBINARY(max) NULL,
 [dtmDueDate] DATETIME NOT NULL,
 [dtmEndTime] DATETIME NULL,
 [intConcurrencyId] INT NOT NULL DEFAULT(0),
 CONSTRAINT [UK_tblAGWorkOrder_strOrderNumber] UNIQUE ([strOrderNumber]),
 CONSTRAINT [FK_tblAGWorkOrder_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
 CONSTRAINT [FK_tblAGWorkOrder_tblEMEntityLocation_FarmField] FOREIGN KEY ([intFarmFieldId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
 --Constraint for app target
 CONSTRAINT [FK_tblAGWorkOrder_tblARSalesperson_intEntitySalesRepId] FOREIGN KEY ([intEntitySalesRepId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
 CONSTRAINT [FK_tblAGWorkOrder_tblEMEntitySplit_intSplitId] FOREIGN KEY ([intSplitId]) REFERENCES [dbo].[tblEMEntitySplit] ([intSplitId]),
 CONSTRAINT [FK_tblAGWorkOrder_tblEMEntity_intOrderedById] FOREIGN KEY ([intOrderedById]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
 CONSTRAINT [PK_dbo.tblAGWorkOrder_intWorkOrderId] PRIMARY KEY CLUSTERED ([intWorkOrderId] ASC)

);

GO

--INSERT STARTING #
CREATE TRIGGER trgWorkOrderNumber
ON dbo.tblAGWorkOrder
AFTER INSERT
AS

DECLARE @inserted TABLE(intWorkOrderId INT)
DECLARE @count INT = 0
DECLARE @intWorkOrderId INT

DECLARE @WorkOrderNumber NVARCHAR(50)

DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = 0

INSERT INTO @inserted
SELECT intWorkOrderId FROM INSERTED ORDER BY intWorkOrderId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SELECT TOP 1 @intWorkOrderId = intWorkOrderId FROM @inserted

	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = 'AG Work Order' 

	IF(@intStartingNumberId <> 0)
		EXEC uspSMGetStartingNumber @intStartingNumberId, @WorkOrderNumber OUT
	
	IF(@WorkOrderNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblAGWorkOrder WHERE strOrderNumber = @WorkOrderNumber)
			BEGIN
				SET @WorkOrderNumber = NULL
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strOrderNumber, 4, 10))) FROM tblAGWorkOrder
				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @WorkOrderNumber OUT
			END
		
		UPDATE tblAGWorkOrder
			SET tblAGWorkOrder.strOrderNumber = @WorkOrderNumber
		FROM tblAGWorkOrder A
		WHERE A.intWorkOrderId = @intWorkOrderId
	END

	DELETE FROM @inserted
	WHERE intWorkOrderId = @intWorkOrderId

END
GO