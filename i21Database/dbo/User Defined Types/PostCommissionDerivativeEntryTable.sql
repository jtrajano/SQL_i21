CREATE TYPE [dbo].[PostCommissionDerivativeEntryTable] AS TABLE (
	[intTransactionId]		INT NOT NULL,
	[dblCommission]			DECIMAL(18, 6) NULL,
	[ysnCommissionOverride]	BIT NOT NULL DEFAULT (0),
	[ysnCommissionExempt]	BIT NOT NULL DEFAULT (0),
	[ysnPosted]	BIT NOT NULL DEFAULT (0)
)