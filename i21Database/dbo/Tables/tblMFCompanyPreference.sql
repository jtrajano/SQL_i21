﻿CREATE TABLE [dbo].[tblMFCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	intDefaultGanttChartViewDuration INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFCompanyPreference_intConcurrencyId] DEFAULT 0,
	[ysnConsiderSumOfChangeoverTime] BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnConsiderSumOfChangeoverTime] DEFAULT 0, 
    [intStandardSetUpDuration] INT NULL, 
    [strDefaultStatusForSanitizedLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnSanitizationInboundPutaway] BIT NULL, 
    [ysnBlendRequirementRequired] BIT NULL DEFAULT 1, 
    [ysnBlendSheetRequired] BIT NULL DEFAULT 1, 
	ysnSanitizationProcessEnabled BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnSanitizationProcessEnabled] DEFAULT 0,
	ysnWIPStagingProcessEnabled BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnWIPStagingProcessEnabled] DEFAULT 0,
	ysnAutoPriorityOrderByDemandRatio BIT,
    ysnDisplayNewOrderByExpectedDate BIT NULL,
	ysnCheckCrossContamination BIT NULL, 
	dtmWorkOrderCreateDate DATETIME,
	strSchedulingCutOffTime NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strScheduleType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intForecastFirstEditableMonth INT CONSTRAINT [DF_tblMFCompanyPreference_intForecastFirstEditableMonth] DEFAULT 0,
	dblDefaultResidueQty NUMERIC(18,6),
	[strDefaultRecipeCost] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [ysnLotHistoryByStorageLocation] BIT NULL, 
	[ysnShowCostInSalesOrderPickList] BIT NULL DEFAULT 0, 
	intWastageWorkOrderDuration INT NULL,
	[intDefaultShipmentStagingLocation] INT,
	[ysnPickByLotCode] BIT NULL DEFAULT 0, 
	[ysnGenerateInvShipmentStagingOrder] BIT NULL DEFAULT 0,
	[intLotCodeStartingPosition] INT NULL, 
    [intLotCodeNoOfDigits] INT NULL, 
	ysnDisplayRecipeTitleByItem BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnDisplayRecipeTitleByItem] DEFAULT 0,
	ysnPickByItemOwner BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnPickByItemOwner] DEFAULT 0,
	ysnDisplayLotIdAsPalletId BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnDisplayLotIdAsPalletId] DEFAULT 0,
	strLotTextInReport NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intBondStatusId int
    CONSTRAINT [PK_tblMFCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]) 
)
