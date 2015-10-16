CREATE TABLE [dbo].[tblMFCompanyPreference]
(
	[intCompanyPreferenceId] INT NOT NULL IDENTITY,
	[ysnEnableParentLot] BIT NOT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnEnableParentLot] DEFAULT 0,
	intDefaultGanttChartViewDuration int NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFCompanyPreference_intConcurrencyId] DEFAULT 0,
	[ysnConsiderSumOfChangeoverTime] BIT NULL CONSTRAINT [DF_tblMFCompanyPreference_ysnConsiderSumOfChangeoverTime] DEFAULT 0, 
    [intStandardSetUpDuration] INT NULL, 
    [strSanitizationStagingLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDefaultStatusForSanitizedLot] NVARCHAR(50) NULL, 
    [dblSanitizationOrderOutputQtyTolerancePercentage] NUMERIC(18, 6) NULL, 
    CONSTRAINT [PK_tblMFCompanyPreference_intCompanyPreferenceId] PRIMARY KEY ([intCompanyPreferenceId]),  
)
