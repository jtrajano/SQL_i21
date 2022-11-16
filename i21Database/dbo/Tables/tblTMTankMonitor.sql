CREATE TABLE [dbo].[tblTMTankMonitor] (
    [intConcurrencyId]    		INT             DEFAULT 1 NOT NULL,
    [intTankMonitorId]          INT             IDENTITY (1, 1) NOT NULL,
	[dtmDateTime]				DATETIME 		NULL,
	[strReadingSource]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
	[intTankNumber]				INT				NULL,
	[strTankStatus]				NVARCHAR (100)   COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
	[intFuelGrade]				INT				NULL,
	[dblFuelVolume]				NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblTempCompensatedVolume]	NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblFuelTemp]				NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblFuelHeight]				NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblWaterHeight]			NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblWaterVolume]			NUMERIC (18, 6) DEFAULT 0 NULL,
	[dblUllage]					NUMERIC (18, 6) DEFAULT 0 NULL,
	CONSTRAINT [PK_tblTMTankMonitor] PRIMARY KEY CLUSTERED ([intTankMonitorId] ASC)
	)






