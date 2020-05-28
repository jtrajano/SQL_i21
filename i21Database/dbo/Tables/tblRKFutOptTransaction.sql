CREATE TABLE [dbo].[tblRKFutOptTransaction]
(
	[intFutOptTransactionId] INT IDENTITY(1,1) NOT NULL,
	[intFutOptTransactionHeaderId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
	[dtmTransactionDate] DATETIME NOT NULL, 
    [intEntityId] INT  NULL, 
    [intBrokerageAccountId] INT  NULL, 
    [intFutureMarketId] INT  NULL, 
	[dblCommission] NUMERIC(18,6) DEFAULT (0),
	[intBrokerageCommissionId] INT NULL,
    [intInstrumentTypeId] INT  NULL, 
    [intCommodityId] INT  NULL, 
    [intLocationId] INT  NULL, 
    [intTraderId] INT  NULL, 
    [intCurrencyId] INT  NULL, 
    [strInternalTradeNo] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [strBrokerTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBuySell] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [dblNoOfContract] NUMERIC(18,6) NULL, 
    [intFutureMonthId] int NULL, 
	[intOptionMonthId] int NULL, 
    [strOptionType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [dblStrike] NUMERIC(18, 6) NULL, 
    [dblPrice] NUMERIC(18, 6) NULL, 
    [strReference] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strStatus] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [dtmFilledDate] DATETIME NULL, 
    [strReserveForFix] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intBookId] INT NULL, 
    [intSubBookId] INT NULL, 
    [ysnOffset] BIT NULL,
	[intBankId] INT NULL,
	[intBankAccountId] INT NULL,
	[intContractDetailId] INT NULL,
	[intContractHeaderId] INT NULL,
	[intSelectedInstrumentTypeId] INT NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[strFromCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strToCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmMaturityDate] DATETIME NULL, 
	[dblContractAmount] NUMERIC(18, 6) NULL, 
	[dblExchangeRate]  NUMERIC(18, 6) NULL,
	[dblMatchAmount] NUMERIC(18, 6) NULL,
	[dblAllocatedAmount] NUMERIC(18, 6) NULL,
	[dblUnAllocatedAmount] NUMERIC(18, 6) NULL,
	[dblSpotRate] NUMERIC(18, 6) NULL,	
	[ysnLiquidation]  BIT NULL,
	[ysnSwap] bit,
	[strRefSwapTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intRefFutOptTransactionId] INT NULL
    CONSTRAINT [PK_tblRKFutOptTransaction_intFutOptTransactionId] PRIMARY KEY (intFutOptTransactionId),	
	[dtmCreateDateTime] DATETIME NULL, 
    [ysnFreezed] BIT NULL, 
    [intRollingMonthId] INT NULL, 
	[intFutOptTransactionRefId] INT NULL,
	[ysnPreCrush] BIT NULL,
    CONSTRAINT [FK_tblRKFutOptTransaction_tblRKFutOptTransactionHeader_intFutOptTransactionHeaderId] FOREIGN KEY ([intFutOptTransactionHeaderId]) REFERENCES [tblRKFutOptTransactionHeader]([intFutOptTransactionHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblRKFutOptTransaction_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblRKOptionsMonth_intOptionMonthId] FOREIGN KEY ([intOptionMonthId]) REFERENCES [tblRKOptionsMonth]([intOptionMonthId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCTSubBook_intBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]), 
	CONSTRAINT [FK_tblRKFutOptTransaction_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCTContractDetail_intContractDetailId] FOREIGN KEY([intContractDetailId])REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCTContractHeader_intContractHeaderId] FOREIGN KEY([intContractHeaderId])REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY(intCurrencyExchangeRateTypeId)REFERENCES [dbo].[tblSMCurrencyExchangeRateType] (intCurrencyExchangeRateTypeId),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank] ([intBankId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblRKFuturesMonth_intRollingMonthId] FOREIGN KEY ([intRollingMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
);

GO

CREATE NONCLUSTERED INDEX [IX_tblRKFutOptTransaction_forDPR]
	ON [dbo].[tblRKFutOptTransaction] ([intFutOptTransactionHeaderId],[strInternalTradeNo])

GO

CREATE TRIGGER trgAfterInsertDerivativeEntry
   ON  tblRKFutOptTransaction
   AFTER  INSERT
AS 

DECLARE @intFutOptTransactionId AS INT,
		@intBrokerageAccountId AS INT,
		@intFutureMarketId AS INT,
		@dtmTransactionDate AS DATETIME,
		@intInstrumentTypeId AS INT,
		@dblCommission AS NUMERIC(18,6),
		@intBrokerageCommissionId AS INT
BEGIN
	
	SET NOCOUNT ON;

    SELECT 
		 @intFutOptTransactionId = intFutOptTransactionId
		,@intBrokerageAccountId = intBrokerageAccountId
		,@intFutureMarketId = intFutureMarketId
		,@dtmTransactionDate = dtmTransactionDate
		,@intInstrumentTypeId = intInstrumentTypeId
	 FROM inserted

	 EXEC uspRKGetCommission @intBrokerageAccountId, @intFutureMarketId, @dtmTransactionDate, @intInstrumentTypeId, @dblCommission OUT, @intBrokerageCommissionId OUT

	 UPDATE tblRKFutOptTransaction SET 
		 dblCommission = @dblCommission
		,intBrokerageCommissionId = @intBrokerageCommissionId
	WHERE intFutOptTransactionId = @intFutOptTransactionId


END

GO
CREATE TRIGGER trgAfterUpdateDerivativeEntry
   ON  tblRKFutOptTransaction
   AFTER  UPDATE
AS 

DECLARE @intFutOptTransactionId AS INT,
		@intBrokerageAccountId AS INT,
		@intFutureMarketId AS INT,
		@dtmTransactionDate AS DATETIME,
		@intInstrumentTypeId AS INT,
		@dblCommission AS NUMERIC(18,6),
		@intBrokerageCommissionId AS INT
BEGIN
	
	SET NOCOUNT ON;

    SELECT 
		 @intFutOptTransactionId = intFutOptTransactionId
		,@intBrokerageAccountId = intBrokerageAccountId
		,@intFutureMarketId = intFutureMarketId
		,@dtmTransactionDate = dtmTransactionDate
		,@intInstrumentTypeId = intInstrumentTypeId
	 FROM inserted

	 EXEC uspRKGetCommission @intBrokerageAccountId, @intFutureMarketId, @dtmTransactionDate, @intInstrumentTypeId, @dblCommission OUT, @intBrokerageCommissionId OUT

	 UPDATE tblRKFutOptTransaction SET 
		 dblCommission = @dblCommission
		,intBrokerageCommissionId = @intBrokerageCommissionId
	WHERE intFutOptTransactionId = @intFutOptTransactionId


END
GO

