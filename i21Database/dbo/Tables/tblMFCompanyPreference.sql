﻿CREATE TABLE [dbo].[tblMFCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	intDefaultGanttChartViewDuration int NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFCompanyPreference_intConcurrencyId] DEFAULT 0,
	[ysnConsiderSumOfChangeoverTime] BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnConsiderSumOfChangeoverTime] DEFAULT 0, 
    [intStandardSetUpDuration] INT NULL, 
    [strDefaultStatusForSanitizedLot] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnSanitizationInboundPutaway] BIT NULL, 
    [ysnBlendRequirementRequired] BIT NULL DEFAULT 1, 
    [ysnBlendSheetRequired] BIT NULL DEFAULT 1, 
	ysnSanitizationProcessEnabled BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnSanitizationProcessEnabled] DEFAULT 0,
	ysnWIPStagingProcessEnabled BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnWIPStagingProcessEnabled] DEFAULT 0,
	ysnAutoPriorityOrderByDemandRatio bit,
    ysnDisplayNewOrderByExpectedDate BIT NULL,
	ysnCheckCrossContamination bit NULL, 
	dtmWorkOrderCreateDate DATETIME,
	ysnIncludeWastageInProductionSummary BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnIncludeWastageInProductionSummary] DEFAULT 0,

    CONSTRAINT [PK_tblMFCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]),  
)
