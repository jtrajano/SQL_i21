CREATE TABLE [dbo].[tblTMFillMethodSkyBitzRef]
(
	[intFillMethodSkyBitzRefId]	INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	
	
	[intNonForecastedId]		INT NULL,
	[intMonitoredId]			INT NULL,
	[intForecastedId]			INT NULL,
	[intDegreeDayId]			INT NULL,

	[intConcurrencyId]			INT NOT NULL DEFAULT(1),

	CONSTRAINT FK_NON_FORECASTED_SKYBITZ_REF_FILL_METHOD FOREIGN KEY ([intNonForecastedId]) REFERENCES dbo.tblTMFillMethod(intFillMethodId),
	CONSTRAINT FK_MONITORED_SKYBITZ_REF_FILL_METHOD FOREIGN KEY ([intMonitoredId]) REFERENCES dbo.tblTMFillMethod(intFillMethodId),
	CONSTRAINT FK_FORECASTED_SKYBITZ_REF_FILL_METHOD FOREIGN KEY ([intForecastedId]) REFERENCES dbo.tblTMFillMethod(intFillMethodId),
	CONSTRAINT FK_DEGREE_DAY_SKYBITZ_REF_FILL_METHOD FOREIGN KEY ([intDegreeDayId]) REFERENCES dbo.tblTMFillMethod(intFillMethodId)
)
