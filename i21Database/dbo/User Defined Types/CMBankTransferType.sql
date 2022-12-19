
CREATE TYPE [dbo].[CMBankTransferType] AS TABLE(
	[dtmDate] [datetime] NOT NULL,
	[strDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceFrom] NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
	[strReferenceTo] NVARCHAR (150)  COLLATE Latin1_General_CI_AS NULL,
	[intBankAccountIdFrom] INT NOT NULL,
	[intGLAccountIdFrom] INT NOT NULL,
	[intBankAccountIdTo] INT NOT NULL,
	[intGLAccountIdTo] INT NOT NULL,
	[intEntityId] INT NULL,
	[dblRateAmountTo] DECIMAL(18, 6) NULL,
    [dblRateAmountFrom] DECIMAL(18, 6) NULL,
	[intFiscalPeriodId] INT NULL,
	[intBankTransferTypeId] INT NULL,
	[dtmAccrual] [datetime] NULL,
	[dtmInTransit] [datetime] NULL,
	[dblCrossRate] DECIMAL(18, 6) NULL,
	[dblReverseRate] DECIMAL(18, 6) NULL,
	[intCurrencyIdAmountFrom] INT NULL,
	[intCurrencyIdAmountTo] INT NULL,
	[dblAmountForeignFrom] DECIMAL(18, 6) NULL,
	[dblAmountForeignTo] DECIMAL(18, 6) NULL,
	[dblAmountFrom] DECIMAL(18, 6) NULL,
	[dblAmountTo] DECIMAL(18, 6) NULL,
	[intRateTypeIdAmountFrom] INT NULL,
	[intRateTypeIdAmountTo] INT NULL,
	[intCurrencyExchangeRateTypeId] INT	NULL,
	--Trade Finance
	[intFutOptTransactionId] INT NULL,
	[intFutOptTransactionHeaderId] INT NULL,
	[strDerivativeId] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
)
 