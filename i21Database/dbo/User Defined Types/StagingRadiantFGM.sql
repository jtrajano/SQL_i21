CREATE TYPE [dbo].[StagingRadiantFGM] AS TABLE(
	[intRowCount] [int] NULL,
	[intFuelGradeID] [int] NULL,
	[dblFuelGradeNonResettableTotalVolume] [numeric](18, 6) NULL,
	[dblFuelGradeNonResettableTotalAmount] [numeric](18, 6) NULL,
	[dblFuelGradeSalesVolume] [numeric](18, 6) NULL,
	[dblFuelGradeSalesAmount] [numeric](18, 6) NULL,
	[dblPumpTestAmount] [numeric](18, 6) NULL,
	[dblPumpTestVolume] [numeric](18, 6) NULL,
	[dblTaxExemptSalesVolume] [numeric](18, 6) NULL,
	[dblDiscountAmount] [numeric](18, 6) NULL,
	[dblDiscountCount] [numeric](18, 6) NULL,
	[dblDispenserDiscountAmount] [numeric](18, 6) NULL,
	[dblDispenserDiscountCount] [numeric](18, 6) NULL
)