CREATE TABLE [dbo].[tblFABookDepreciationReport]
(
	[intBookDepreciationReportId] INT IDENTITY(1, 1) NOT NULL,
	[intEntityId] INT NOT NULL,
	[intAssetId] INT NOT NULL,
	[intFiscalPeriodId] INT NOT NULL,

	[intLedgerIdLeft] INT NULL,
	[intTotalDepreciatedLeft] INT NULL,
	[intTotalDepreciationLeft] INT NULL,
	[intDepreciationMethodIdLeft] INT NULL,
	[dblCostLeft] NUMERIC(18 ,6) NULL,
	[dblSalvageValueLeft] NUMERIC(18, 6) NULL,
	[dblBonusDepreciationLeft] NUMERIC(18, 6) NULL,
	[dblSection179Left] NUMERIC(18, 6) NULL,
	[dblDepreciationCurrentMonthLeft] NUMERIC(18, 6) NULL,
	[dblDepreciationYTDLeft] NUMERIC(18, 6) NULL,
	[dblDepreciationLTDLeft] NUMERIC(18, 6) NULL,

	[intLedgerIdRight] INT NULL,
	[intTotalDepreciatedRight] INT NULL,
	[intTotalDepreciationRight] INT NULL,
	[intDepreciationMethodIdRight] INT NULL,
	[dblCostRight] NUMERIC(18 ,6) NULL,
	[dblSalvageValueRight] NUMERIC(18, 6) NULL,
	[dblBonusDepreciationRight] NUMERIC(18, 6) NULL,
	[dblSection179Right] NUMERIC(18, 6) NULL,
	[dblDepreciationCurrentMonthRight] NUMERIC(18, 6) NULL,
	[dblDepreciationYTDRight] NUMERIC(18, 6) NULL,
	[dblDepreciationLTDRight] NUMERIC(18, 6) NULL,

	[dblDifferenceMTD] NUMERIC(18, 6) NULL,
	[dblDifferenceYTD] NUMERIC(18, 6) NULL,
	[dblDifferenceLTD] NUMERIC(18, 6) NULL,

	CONSTRAINT [PK_tblFABookDepreciationReport] PRIMARY KEY CLUSTERED ([intBookDepreciationReportId] ASC)
)
