CREATE TYPE [dbo].[CMCashFlowReportFilterRateType] AS TABLE (
	[intFilterCurrencyId]	INT NOT NULL,
	[dblRateBucket1]		NUMERIC(18,6) NULL,
	[dblRateBucket2]		NUMERIC(18,6) NULL,
	[dblRateBucket3]		NUMERIC(18,6) NULL,
	[dblRateBucket4]		NUMERIC(18,6) NULL,
	[dblRateBucket5]		NUMERIC(18,6) NULL,
	[dblRateBucket6]		NUMERIC(18,6) NULL,
	[dblRateBucket7]		NUMERIC(18,6) NULL,
	[dblRateBucket8]		NUMERIC(18,6) NULL,
	[dblRateBucket9]		NUMERIC(18,6) NULL
)