CREATE TABLE [dbo].[tblRKSettlementPriceImport]
( 
	[intImportSettlementPriceId] INT IDENTITY(1,1) NOT NULL,
	[dtmPriceDate] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strFutureMarket] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strInstrumentType] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	[strFutureMonth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblLastSettle] decimal(24,10) NULL,
	[dblLow] decimal(24,10) NULL,
	[dblHigh] decimal(24,10) NULL,
	[strFutComments] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strOptionMonth] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblStrike] decimal(24,10) NULL,
	[strType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblSettle] decimal(24,10) NULL,
	[dblDelta] decimal(24,10),
	[intConcurrencyId] int NOT NULL
)