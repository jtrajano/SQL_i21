
CREATE TYPE [dbo].[CMBankTransferType] AS TABLE(
	[dtmDate] [datetime] NOT NULL,
	[strDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[intBankAccountIdFrom] [int] NOT NULL,
	[intGLAccountIdFrom] [int] NOT NULL,
	[intBankAccountIdTo] [int] NOT NULL,
	[intGLAccountIdTo] [int] NOT NULL,
	[intEntityId] [int] NULL,
	[dblRateAmountTo] [decimal](18, 6) NULL,
    [dblRateAmountFrom] [decimal](18, 6) NULL,
	[intFiscalPeriodId] [int] NULL,
	[intBankTransferTypeId] [int] NULL,
	[dtmAccrual] [datetime] NULL,
	[dtmInTransit] [datetime] NULL,
	[dblCrossRate] [decimal](18, 6) NULL,
	[dblReverseRate] [decimal](18, 6) NULL,
	[intCurrencyIdAmountFrom] [int] NULL,
	[intCurrencyIdAmountTo] [int] NULL,
	[dblAmountForeignFrom] [decimal](18, 6) NULL,
	[dblAmountForeignTo] [decimal](18, 6) NULL,
	[dblAmountFrom] [decimal](18, 6) NULL,
	[dblAmountTo] [decimal](18, 6) NULL,
	[intRateTypeIdAmountFrom] [int] NULL,
	[intRateTypeIdAmountTo] [int] NULL,
	[strDerivativeIdId] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyExchangeRateTypeId] INT	NULL
)
 