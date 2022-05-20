CREATE TABLE [dbo].[tblSMShipViaTrailerCompartment]
(
	[intEntityShipViaTrailerCompartmentId]		INT				IDENTITY(1,1) NOT NULL,
	[intEntityShipViaTrailerId]					INT				NOT NULL,
	[strCompartmentNumber]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
	[intCategoryId]								INT				NULL,
	[dblCapacity]								NUMERIC (18, 6) NULL,

	[intConcurrencyId]							INT				NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipViaTrailerCompartment] PRIMARY KEY CLUSTERED ([intEntityShipViaTrailerCompartmentId] ASC), 
	CONSTRAINT [FK_dbo_tblSMShipViaTrailerCompartment_tblSMShipViaTrailer] FOREIGN KEY ([intEntityShipViaTrailerId]) REFERENCES [dbo].tblSMShipViaTrailer ([intEntityShipViaTrailerId]) ON DELETE CASCADE
)
