CREATE TYPE [dbo].[PostCommissionDerivativeEntryTable] AS TABLE (
	[intMatchNo]			INT NULL,
	[strInternalTradeNo]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCommissionRateType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblCommission]			DECIMAL(18, 6) NULL,
	[ysnCommissionOverride]	BIT NULL,
	[strBankTransactionId]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)