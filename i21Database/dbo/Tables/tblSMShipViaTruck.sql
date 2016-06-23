CREATE TABLE [dbo].[tblSMShipViaTruck]
(
	[intEntityShipViaTruckId]       INT				IDENTITY(1,1) NOT NULL,
	[intEntityShipViaId]			INT				NOT NULL,
	[strTruckNumber]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS NOT NULL,
	[dblTruckCapacity]				NUMERIC (18, 6) NOT NULL,
	[dblTimePerStop]				NUMERIC (18, 6) NOT NULL,
	[dblPumpingQty]					NUMERIC (18, 6) NOT NULL,
	[dblAverageSpeed]				NUMERIC (18, 6) NOT NULL,
	[dblReloadPumpingQty]			NUMERIC (18, 6) NOT NULL,
	[dblLeakCheckTime]				NUMERIC (18, 6) NOT NULL,

	[intConcurrencyId]				INT				NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMShipViaTruck] PRIMARY KEY CLUSTERED ([intEntityShipViaTruckId] ASC), 
	CONSTRAINT [FK_dbo_tblSMShipViaTruck_tblSMShipVia_] FOREIGN KEY ([intEntityShipViaId]) REFERENCES [dbo].tblSMShipVia ([intEntityShipViaId]) ON DELETE CASCADE,

)