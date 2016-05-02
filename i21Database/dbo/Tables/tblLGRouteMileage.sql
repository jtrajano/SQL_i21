CREATE TABLE [dbo].[tblLGRouteMileage]
(
	[intRouteMileageId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intRouteId] INT NOT NULL, 	
	[strCity] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strZip] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblLon] NUMERIC(18, 6) NULL,
	[dblLat] NUMERIC(18, 6) NULL,
	[dblLCostMile] NUMERIC(18, 6) NULL,
	[dblLEstghg] NUMERIC(18, 6) NULL,
	[dblLHours] NUMERIC(18, 6) NULL,
	[dblLMiles] NUMERIC(18, 6) NULL,
	[dblLTolls] NUMERIC(18, 6) NULL,
	[dblTCostMile] NUMERIC(18, 6) NULL,
	[dblTEstghg] NUMERIC(18, 6) NULL,
	[dblTHours] NUMERIC(18, 6) NULL,
	[dblTMiles] NUMERIC(18, 6) NULL,
	[dblTTolls] NUMERIC(18, 6) NULL,

    CONSTRAINT [PK_tblLGRouteMileage] PRIMARY KEY ([intRouteMileageId]),
    CONSTRAINT [FK_tblLGRouteMileage_tblLGRoute_intRouteId] FOREIGN KEY ([intRouteId]) REFERENCES [tblLGRoute]([intRouteId]) ON DELETE CASCADE
)
