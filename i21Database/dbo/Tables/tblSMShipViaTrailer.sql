CREATE TABLE [dbo].[tblSMShipViaTrailer]
(
	[intEntityShipViaTrailerId]     INT				IDENTITY(1,1) NOT NULL,
	[intEntityShipViaId]			INT				NOT NULL,
	[strTrailerLicenseNumber]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strTrailerNumber]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[strTrailerDescription]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS NULL,
	[strType]						NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL,
	[dblNumberOfCompartments]		NUMERIC (18, 6) NULL,
	[dtmLicenseExpirationDate]		DATETIME		NULL,
	[dblTareWeight]					NUMERIC (18, 6) NULL,
	[strTruckAssigned]				NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL,
	[strTrailerStatus]				NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL,
	[dtmStatusEffectiveDate]		DATETIME		NULL,

	[intConcurrencyId]				INT				NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipViaTrailer] PRIMARY KEY CLUSTERED ([intEntityShipViaTrailerId] ASC), 
	CONSTRAINT [FK_dbo_tblSMShipViaTrailer_tblSMShipVia_] FOREIGN KEY ([intEntityShipViaId]) REFERENCES [dbo].tblSMShipVia ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [UK_tblSMShipViaTrailer_intEntityShipViaId_strTrailerLicenseNumber] UNIQUE NONCLUSTERED ([strTrailerLicenseNumber] ASC,[intEntityShipViaId] ASC)	
 )