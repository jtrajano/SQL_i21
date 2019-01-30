CREATE TABLE [dbo].[tblRKSettlementPriceImport]
( 
	[intImportSettlementPriceId] INT IDENTITY(1,1) NOT NULL,
	[dtmPriceDate] DATETIME NOT NULL,
	[strFutureMarket] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strInstrumentType] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strFutureMonth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblLastSettle] NUMERIC(18, 6) NULL,
	[dblLow] NUMERIC(18, 6) NULL,
	[dblHigh] NUMERIC(18, 6) NULL,
	[strFutComments] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strOptionMonth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblStrike] NUMERIC(18, 6) NULL,
	[strType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblSettle] NUMERIC(18, 6) NULL,
	[dblDelta] NUMERIC(18, 6),
	[intConcurrencyId] int NOT NULL
)