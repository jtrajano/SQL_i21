CREATE TABLE [dbo].[tblDBRiskDemoOptionSensitivity]
(
	[intRiskDemoOptionSensitivityId]			INT IDENTITY (1, 1) NOT NULL,
	[strDescription]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strExchange]								[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSymbol]									[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intQuantity]								INT NULL,
	[dblLastPrice]								NUMERIC (16, 12) NULL,
	[dblMarketValue]							NUMERIC (16, 2) NULL,
	[dblDelta]									NUMERIC (16, 12) NULL,
	[dblGamma]									NUMERIC (16, 12) NULL,
	[dblVega]									NUMERIC (16, 12) NULL,
	[dblTheta]									NUMERIC (16, 12) NULL,
	[dblRho]									NUMERIC (16, 12) NULL,
	[intConcurrencyId]							[int] NOT NULL DEFAULT ((1)), 

	CONSTRAINT [PK_tblDBRiskDemoOptionSensitivity] PRIMARY KEY CLUSTERED (intRiskDemoOptionSensitivityId ASC),
)
