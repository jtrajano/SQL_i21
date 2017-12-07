﻿CREATE TABLE [dbo].[tblMFCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	intDefaultGanttChartViewDuration INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFCompanyPreference_intConcurrencyId] DEFAULT 0,
	[ysnConsiderSumOfChangeoverTime] BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnConsiderSumOfChangeoverTime] DEFAULT 0, 
    [intStandardSetUpDuration] INT NULL, 
    [strDefaultStatusForSanitizedLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,--Not used
    intDefaultStatusForSanitizedLot int,
	[ysnSanitizationInboundPutaway] BIT NULL, 
    [ysnBlendRequirementRequired] BIT NULL DEFAULT 1, 
    [ysnBlendSheetRequired] BIT NULL DEFAULT 1, 
	ysnSanitizationProcessEnabled BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnSanitizationProcessEnabled] DEFAULT 0,--Not used
	ysnWIPStagingProcessEnabled BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnWIPStagingProcessEnabled] DEFAULT 0,--Not used
	ysnAutoPriorityOrderByDemandRatio BIT,
    ysnDisplayNewOrderByExpectedDate BIT NULL,
	ysnCheckCrossContamination BIT NULL, 
	dtmWorkOrderCreateDate DATETIME,
	strSchedulingCutOffTime NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strScheduleType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intForecastFirstEditableMonth INT CONSTRAINT [DF_tblMFCompanyPreference_intForecastFirstEditableMonth] DEFAULT 0,
	dblDefaultResidueQty NUMERIC(18,6),
	[strDefaultRecipeCost] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,--Not used
    [ysnLotHistoryByStorageLocation] BIT NULL, 
	[ysnShowCostInSalesOrderPickList] BIT NULL DEFAULT 0, 
	intWastageWorkOrderDuration INT NULL,
	[intDefaultShipmentStagingLocation] INT,
	[intDefaultShipmentDockDoorLocation] INT,
	[ysnPickByLotCode] BIT NULL DEFAULT 0, 
	[ysnGenerateInvShipmentStagingOrder] BIT NULL DEFAULT 1,
	[intLotCodeStartingPosition] INT NULL, 
    [intLotCodeNoOfDigits] INT NULL, 
	ysnDisplayRecipeTitleByItem BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnDisplayRecipeTitleByItem] DEFAULT 0,
	ysnPickByItemOwner BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnPickByItemOwner] DEFAULT 0,
	ysnDisplayLotIdAsPalletId BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnDisplayLotIdAsPalletId] DEFAULT 0,
	strLotTextInReport NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intBondStatusId int,
	ysnSetExpiryDateByParentLot bit,
    ysnAddQtyOnExistingLot BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnAddQtyOnExistingLot] DEFAULT 1, 
	ysnNotifyInventoryShortOnCreateWorkOrder BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnNotifyInventoryShortOnCreateWorkOrder] DEFAULT 0, 
	ysnNotifyInventoryShortOnReleaseWorkOrder BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnNotifyInventoryShortOnReleaseWorkOrder] DEFAULT 0, 
	ysnSetDefaultQtyOnHandheld BIT,
	ysnEnableStagingBOL BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnEnableStagingBOL] DEFAULT 0,
	strBOLReportName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnReserveOnStage Bit NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnReserveOnStage] DEFAULT 1,
	ysnGenerateNewParentLotOnChangeItem Bit NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnGenerateNewParentLotOnChangeItem] DEFAULT 0,
	intNoOfDecimalPlacesOnConsumption int NULL CONSTRAINT [DF_tblMFCompanyPreference_intNoOfDecimalPlacesOnConsumption] DEFAULT 0,
	ysnConsumptionByRatio Bit NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnConsumptionByRatio] DEFAULT 1,
	ysnSetDefaultQty BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnSetDefaultQty] DEFAULT 1,
	ysnLoadProcessEnabled Bit NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnLoadProcessEnabled] DEFAULT 1,
	ysnSplitLotOnPartialQty Bit NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnSplitLotOnPartialQty] DEFAULT 0,
	ysnProducedQtyByUnitCount Bit NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnProducedQtyByUnitCount] DEFAULT 1,
	intDamagedStatusId int,
	intIRParentLotNumberPatternId int,

	ysnAllowMoveAssignedTask BIT,
	intAllowablePickDayRange INT,
	ysnGTINCaseCodeMandatory BIT,
	intMaximumPalletsOnForklift INT,

    CONSTRAINT [PK_tblMFCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]) 
)
