CREATE TABLE [dbo].[tblDBRiskDemoStressTestingIndex]
(
	[intRiskDemoStressTestingIndexId]			INT IDENTITY (1, 1) NOT NULL,
	[strDescription]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strExchange]								[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSymbol]									[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intQuantity]								INT NULL,
	[dblLastPrice]								NUMERIC (16, 2) NULL,
	[dblMarketValue]							NUMERIC (16, 2) NULL,
	[strIndex]									[nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strStressType]								[nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[dblSpotStress]								NUMERIC (16, 2) NULL,
	[dblVolatilityStress]						NUMERIC (16, 2) NULL,
	[dblIndexStress]							NUMERIC (16, 2) NULL,
	[dblStressPrice]							NUMERIC (16, 10) NULL,
	[dblStressImpact]							NUMERIC (16, 2) NULL,
	[dblTotalStressImpact]						NUMERIC (16, 2) NULL,
	[dtmStartDate]								[datetime] NULL, 
	[intConcurrencyId]							[int] NOT NULL DEFAULT ((1)), 

	CONSTRAINT [PK_tblDBRiskDemoStressTestingIndex] PRIMARY KEY CLUSTERED ([intRiskDemoStressTestingIndexId] ASC),
)
