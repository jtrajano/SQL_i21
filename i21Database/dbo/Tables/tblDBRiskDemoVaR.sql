CREATE TABLE [dbo].[tblDBRiskDemoVaR]
(
	[intRiskDemoVaRId]							INT IDENTITY (1, 1) NOT NULL,
	[strDescription]							[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[strExchange]								[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSymbol]									[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intQuantity]								INT NULL,
	[dblLastPrice]								NUMERIC (16, 2) NULL,
	[dblMarketValue]							NUMERIC (16, 2) NULL,
	[dblVaR]									NUMERIC (16, 2) NULL,
	[dblComponentVaR]							NUMERIC (16, 2) NULL,
	[dblConditionalVaR]							NUMERIC (16, 2) NULL,
	[dblTotalVaR]								NUMERIC (16, 2) NULL,
	[dblTotalConditionalVaR]					NUMERIC (16, 2) NULL,
	[strVaRModel]								[nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[dblConfidence]								NUMERIC (16, 2) NULL,
	[dtmStartDate]								[datetime] NULL, 
	[strBaseFX]									[nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]							[int] NOT NULL DEFAULT ((1)), 

	CONSTRAINT [PK_tblDBRiskDemoVaR] PRIMARY KEY CLUSTERED ([intRiskDemoVaRId] ASC),
)
