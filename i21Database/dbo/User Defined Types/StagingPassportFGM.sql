CREATE TYPE StagingPassportFGM AS TABLE
(
	[intRowCount] 									INT				NULL,
	[intFuelGradeID]								INT				NULL,
	
	[dblFuelGradeNonResettableTotalVolume]			NUMERIC(18,6)     NULL,
	[dblFuelGradeNonResettableTotalAmount]			NUMERIC(18,6)     NULL,
	[dblFuelGradeSalesVolume]						NUMERIC(18,6)     NULL,
	[dblFuelGradeSalesAmount]						NUMERIC(18,6)     NULL,
	[dblPumpTestAmount]								NUMERIC(18,6)     NULL,
	[dblPumpTestVolume]								NUMERIC(18,6)     NULL,
	[dblTaxExemptSalesVolume]						NUMERIC(18,6)     NULL,
	[dblDiscountAmount]								NUMERIC(18,6)     NULL,
	[dblDiscountCount]								NUMERIC(18,6)     NULL,
	[dblDispenserDiscountAmount]					NUMERIC(18,6)     NULL,
	[dblDispenserDiscountCount]						NUMERIC(18,6)     NULL
)
