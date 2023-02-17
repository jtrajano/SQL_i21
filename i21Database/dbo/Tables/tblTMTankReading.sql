CREATE TABLE [dbo].[tblTMTankReading] (
    [intConcurrencyId]    		INT             DEFAULT 1 NOT NULL,
    [intTankReadingId]          INT             IDENTITY (1, 1) NOT NULL,
	[dtmDateTime]				DATETIME 		NULL,
	[intReadingSource]			INT NULL,
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
	[strSerialNumber]			NVARCHAR (100)  COLLATE Latin1_General_CI_AS DEFAULT ('') NULL,
	[intDeviceId]				INT				NULL,
	[intSiteId]					INT				NULL,
	[dblInventoryReading] NUMERIC (18, 6) DEFAULT 0 NULL,
	[dtmInventoryReadingDateTime]				DATETIME 		NULL,
    [ysnManual]  bit NULL,
	[intCheckoutId] int NULL
	CONSTRAINT [PK_tblTMTankReading_intTankReadingId] PRIMARY KEY CLUSTERED ([intTankReadingId] ASC),
	CONSTRAINT [FK_tblTMTankReading_tblTMReadingSourceType] FOREIGN KEY ([intReadingSource]) REFERENCES [dbo].[tblTMReadingSourceType] ([intReadingSourceTypeId])
	)






