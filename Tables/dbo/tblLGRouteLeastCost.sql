CREATE TABLE [dbo].[tblLGRouteLeastCost]
(
	[intRouteLeastCostId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intRouteId] INT NOT NULL, 
	[strRoute] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblCost] NUMERIC(18, 6) NULL,
	[dblEstghg] NUMERIC(18, 6) NULL,
	[dblFuel] NUMERIC(18, 6) NULL,
	[dblHours] NUMERIC(18, 6) NULL,
	[dblLabor] NUMERIC(18, 6) NULL,
	[strTripOptions] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblMiles] NUMERIC(18, 6) NULL,
	[dblOther] NUMERIC(18, 6) NULL,
	[dblTolls] NUMERIC(18, 6) NULL,

    CONSTRAINT [PK_tblLGRouteLeastCost] PRIMARY KEY ([intRouteLeastCostId]),
    CONSTRAINT [FK_tblLGRouteLeastCost_tblLGRoute_intRouteId] FOREIGN KEY ([intRouteId]) REFERENCES [tblLGRoute]([intRouteId]) ON DELETE CASCADE
)
