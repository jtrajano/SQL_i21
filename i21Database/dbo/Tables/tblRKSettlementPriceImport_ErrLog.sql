CREATE TABLE [dbo].[tblRKSettlementPriceImport_ErrLog]
(
	[intImportSettlementPriceErrLogId] INT IDENTITY(1,1) NOT NULL,
	[intImportSettlementPriceId] INT ,
	[dtmPriceDate] DATETIME NULL,
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
	[strErrorMsg] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] int NOT NULL
)