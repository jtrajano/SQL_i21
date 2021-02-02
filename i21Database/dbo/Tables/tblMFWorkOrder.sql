﻿CREATE TABLE [dbo].[tblMFWorkOrder]
(
	[intWorkOrderId] INT NOT NULL IDENTITY(1,1), 
    [strWorkOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL , 
	strReferenceNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmOrderDate] DATETIME NULL, 
    [intItemId] INT NULL, 
    [dblQuantity] NUMERIC(18, 6) NULL, 
    [intItemUOMId] INT NULL, 
    [intStatusId] INT NOT NULL, 
	[intManufacturingCellId] INT NULL, 
    [intStorageLocationId] INT NULL,
	[intLocationId] INT NOT NULL,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
    [dtmExpectedDate] DATETIME NULL, 
    [intExecutionOrder] INT NULL, 
	[dtmReleasedDate] DATETIME NULL, 
    [dtmStartedDate] DATETIME NULL, 
    [dtmCompletedDate] DATETIME NULL, 
    [dtmOnHoldDate] DATETIME NULL, 
    [intProductionTypeId] INT NULL,
	[dblProducedQuantity] NUMERIC(18, 6) NULL CONSTRAINT [DF_tblMFWorkOrder_dblProducedQuantity] DEFAULT 0, 
    [dtmActualProductionStartDate] DATETIME NULL, 
    [dtmActualProductionEndDate] DATETIME NULL,	
	[ysnUseTemplate] BIT NULL CONSTRAINT [DF_tblMFWorkOrder_ysnUseTemplate] DEFAULT 0, 
    [dblBinSize] NUMERIC(18, 6) NULL, 
    [dblPlannedQuantity] NUMERIC(18, 6) NULL, 
	[dblStagedQty] NUMERIC(18, 6) NULL, 
    [intMachineId] INT NULL, 
    [intStagingLocationId] INT NULL,
	[dtmStagedDate] DATETIME NULL,
	[intParentWorkOrderId] INT NULL, 
    [intBlendRequirementId] INT NULL, 
    [intPickListId] INT NULL, 
    [ysnKittingEnabled] BIT NULL CONSTRAINT [DF_tblMFWorkOrder_ysnKittingEnabled] DEFAULT 0,
	ysnDietarySupplements BIT NULL CONSTRAINT [DF_tblMFWorkOrder_ysnDietarySupplements] DEFAULT 0,
	[intKitStatusId] INT NULL,
    [intProductOwnerId] INT NULL,  
    [intCustomerId] INT NULL, 
    [strSalesOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCustomerOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strERPOrderNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intSalesOrderLineItemId] INT NULL, 
	[intInvoiceDetailId] INT NULL, 
	[intLoadDistributionDetailId] INT NULL, 
    [strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strVendorLotNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intOrderHeaderId] INT NULL, 
    [strBOLNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmEarliestDate] DATETIME NULL, 
    [dtmLatestDate] DATETIME NULL, 
    [dtmEarliestStartDate] DATETIME NULL, 
    [intSalesRepresentativeId] INT NULL, 
    [dtmPlannedDate] DATETIME NULL, 
    [intPlannedShiftId] INT NULL, 
    [intActualShiftId] INT NULL, 
	[strSpecialInstruction] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intBatchID] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFWorkOrder_intConcurrencyId] DEFAULT 0,
	intManufacturingProcessId INT, 
	intSupervisorId INT,
	intSubLocationId INT,
	ysnIngredientAvailable bit CONSTRAINT [DF_tblMFWorkOrder_ysnIngredientAvailable] DEFAULT 1,
	intCountStatusId INT NULL, 
	intDepartmentId int,
	strBatchId nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	intInboundOrderHeaderId INT NULL, 
	strInboundBOLNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	dtmLastProducedDate datetime,
	ysnFeedCloseWorkorder bit CONSTRAINT [DF_tblMFWorkOrder_ysnFeedCloseWorkorder] DEFAULT 0,
	intTransactionFrom int CONSTRAINT [DF_tblMFWorkOrder_intTransactionFrom] DEFAULT 3,
	strCostAdjustmentBatchId nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	intRecipeTypeId INT,
	intCompanyId INT NULL,
	dtmPostDate datetime,
	dblInputItemValue NUMERIC(38, 20) NULL, 
	strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	strVesselNo nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	dblActualQuantity NUMERIC(18, 6) NULL, 
	dblNoOfUnits NUMERIC(18, 6) NULL, 
	intNoOfUnitsItemUOMId int,
	intLoadId int,
	intWarehouseRateMatrixHeaderId int,
	strERPServicePONumber nvarchar(50) COLLATE Latin1_General_CI_AS,
    CONSTRAINT [PK_tblMFWorkOrder_intWorkOrderId] PRIMARY KEY (intWorkOrderId),
	CONSTRAINT [UQ_tblMFWorkOrder_strWorkOrderNo] UNIQUE ([strWorkOrderNo]),
	CONSTRAINT [FK_tblMFWorkOrder_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblMFWorkOrder_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblMFWorkOrder_tblMFWorkOrderStatus_intStatusId] FOREIGN KEY ([intStatusId]) REFERENCES [tblMFWorkOrderStatus]([intStatusId]), 
	CONSTRAINT [FK_tblMFWorkOrder_tblMFProductionType_intProductionTypeId] FOREIGN KEY ([intProductionTypeId]) REFERENCES [tblMFWorkOrderProductionType]([intProductionTypeId]), 
	CONSTRAINT [FK_tblMFWorkOrder_tblMFBlendRequirement_intBlendRequirementId] FOREIGN KEY ([intBlendRequirementId]) REFERENCES [tblMFBlendRequirement]([intBlendRequirementId]), 
	CONSTRAINT [FK_tblMFWorkOrder_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
	CONSTRAINT [FK_tblMFWorkOrder_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblMFWorkOrder_tblMFManufacturingProcess_intManufacturingProcessId] FOREIGN KEY([intManufacturingProcessId]) REFERENCES dbo.tblMFManufacturingProcess (intManufacturingProcessId),
	CONSTRAINT FK_tblMFWorkOrder_tblSMCompanyLocationSubLocation_intSubLocationId FOREIGN KEY(intSubLocationId) REFERENCES dbo.tblSMCompanyLocationSubLocation (intCompanyLocationSubLocationId),
	CONSTRAINT [FK_tblMFWorkOrder_intCountStatusId_tblMFWorkOrderStatus_intStatusId] FOREIGN KEY ([intCountStatusId]) REFERENCES [tblMFWorkOrderStatus]([intStatusId]), 
	CONSTRAINT [FK_tblMFWorkOrder_tblMFDepartment_intDepartmentId] FOREIGN KEY ([intDepartmentId]) REFERENCES [tblMFDepartment]([intDepartmentId]),
	CONSTRAINT [FK_tblMFWorkOrder_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrder_tblMFWorkOrderStatus_intKitStatusId] FOREIGN KEY ([intKitStatusId]) REFERENCES [tblMFWorkOrderStatus]([intStatusId]),
	CONSTRAINT [FK_tblMFWorkOrder_tblLGWarehouseRateMatrixHeader_intWarehouseRateMatrixHeaderId] FOREIGN KEY (intWarehouseRateMatrixHeaderId) REFERENCES tblLGWarehouseRateMatrixHeader(intWarehouseRateMatrixHeaderId)
)
Go
CREATE NONCLUSTERED INDEX IX_tblMFWorkOrder_intWorkOrderId ON [dbo].[tblMFWorkOrder]
(
	[intWorkOrderId] ASC,
	[intPlannedShiftId] ASC,
	[intManufacturingProcessId] ASC,
	[intManufacturingCellId] ASC,
	[intStatusId] ASC,
	[intItemId] ASC,
	[intItemUOMId] ASC
)
INCLUDE ( 	[strWorkOrderNo],
	[dtmOrderDate],
	[dblQuantity],
	[dtmPlannedDate],
	[strComment]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
Go
CREATE NONCLUSTERED INDEX IX_tblMFWorkOrder_intStatusId ON [dbo].[tblMFWorkOrder]
(
	[intStatusId] ASC,
	[intWorkOrderId] ASC
)
INCLUDE ( 	[dtmPlannedDate]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]