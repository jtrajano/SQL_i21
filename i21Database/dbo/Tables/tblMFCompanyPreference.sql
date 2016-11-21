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

    CONSTRAINT [PK_tblMFCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId])
)
