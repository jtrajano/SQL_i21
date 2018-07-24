CREATE TABLE [dbo].[tblSMShipViaTrailer]
(
	[intEntityShipViaTrailerId]     INT				IDENTITY(1,1) NOT NULL,
	[intEntityShipViaId]			INT				NOT NULL,
	[strTrailerLicenseNumber]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]				INT				NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipViaTrailer] PRIMARY KEY CLUSTERED ([intEntityShipViaTrailerId] ASC), 
	CONSTRAINT [FK_dbo_tblSMShipViaTrailer_tblSMShipVia_] FOREIGN KEY ([intEntityShipViaId]) REFERENCES [dbo].tblSMShipVia ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [UK_tblSMShipViaTrailer_intEntityShipViaId_strTrailerLicenseNumber] UNIQUE NONCLUSTERED ([strTrailerLicenseNumber] ASC,[intEntityShipViaId] ASC)	
)