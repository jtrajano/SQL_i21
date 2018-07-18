﻿CREATE TABLE [dbo].[tblMFCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	intDefaultGanttChartViewDuration INT NULL,
	intDefaultMaterialRequirementDuration INT NULL,
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
	strParentLotTextInReport NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
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
	ysnAllowLotMoveacrossLocations BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnAllowLotMoveacrossLocations] DEFAULT 0,
	ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType Bit CONSTRAINT [DF_tblMFCompanyPreference_ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType] DEFAULT 0,
	intLotDueDays int CONSTRAINT [DF_tblMFCompanyPreference_intLotDueDays] DEFAULT 0,
	ysnLifeTimeByEndOfMonth BIT CONSTRAINT [DF_tblMFCompanyPreference_ysnLifeTimeByEndOfMonth] DEFAULT 0,
	ysnSendEDIOnRepost Bit CONSTRAINT [DF_tblMFCompanyPreference_ysnSendEDIOnRepost] DEFAULT 1,
	ysnGenerateTaskOnCreatePickOrder Bit CONSTRAINT [DF_tblMFCompanyPreference_ysnGenerateTaskOnCreatePickOrder] DEFAULT 0,
	ysnLotSnapshotByFiscalMonth BIT CONSTRAINT [DF_tblMFCompanyPreference_ysnLotSnapshotByFiscalMonth] DEFAULT 1,
	intPreProductionControlPointId INT,
	dblDemandUsageDays NUMERIC(18,6),
	strStartDayOfTheWeekForDemandPlanning NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	ysnConsiderCurrentWeekForDemandPlanning BIT Default 1,
	dblAverageWeekTransitPeriodForDemandPlanning NUMERIC(18,6),
	ysnIncludeConsumptionByLocationInPickOrder BIT CONSTRAINT [DF_tblMFCompanyPreference_ysnIncludeConsumptionByLocationInPickOrder] DEFAULT 1,
	ysnCostEnabled BIT CONSTRAINT [DF_tblMFCompanyPreference_ysnCostEnabled] DEFAULT 1,
	ysnLotNumberUniqueByItem Bit CONSTRAINT [DF_tblMFCompanyPreference_ysnLotNumberUniqueByItem] DEFAULT 1,
	ysnMergeOnMove Bit CONSTRAINT [DF_tblMFCompanyPreference_ysnMergeOnMove] DEFAULT 0,
    CONSTRAINT [PK_tblMFCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]) 
)
