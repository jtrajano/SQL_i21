CREATE TYPE [dbo].[PostCommissionDerivativeEntryTable] AS TABLE (
	[intTransactionId]		INT NOT NULL,
	[intMatchNo]			INT NULL,
	[strInternalTradeNo]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCommissionRateType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblCommission]			DECIMAL(18, 6) NULL,
	[ysnCommissionOverride]	BIT NOT NULL DEFAULT (0),
	[ysnPosted]				BIT NOT NULL DEFAULT (0)
)