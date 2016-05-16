﻿CREATE TABLE [dbo].[tblRKFutOptTransaction]
(
	[intFutOptTransactionId] INT IDENTITY(1,1) NOT NULL,
	[intFutOptTransactionHeaderId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
	[dtmTransactionDate] DATETIME NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [intBrokerageAccountId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intInstrumentTypeId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
    [intLocationId] INT NOT NULL, 
    [intTraderId] INT NOT NULL, 
    [intCurrencyId] INT NOT NULL, 
    [strInternalTradeNo] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strBrokerTradeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strBuySell] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intNoOfContract] INT NOT NULL, 
    [intFutureMonthId] int NULL, 
	[intOptionMonthId] int NULL, 
    [strOptionType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [dblStrike] NUMERIC(18, 6) NULL, 
    [dblPrice] NUMERIC(18, 6) NOT NULL, 
    [strReference] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [strStatus] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmFilledDate] DATETIME NULL, 
    [strReserveForFix] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intBookId] INT NULL, 
    [intSubBookId] INT NULL, 
    [ysnOffset] BIT NULL,
	[intBankId] INT,
	[intBankAccountId] INT,
	[intContractDetailId] INT NULL,
	[intSelectedInstrumentTypeId] INT NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[intFromCurrencyId] INT NULL,
	[intToCurrencyId] INT NULL,
	[dblExchangeRate]  NUMERIC(18, 6) NULL,
	[dblMatchAmount] NUMERIC(18, 6) NULL,
	[dblAllocatedAmount] NUMERIC(18, 6) NULL,
	[dblUnAllocatedAmount] NUMERIC(18, 6) NULL,
	[dblSpotRate] NUMERIC(18, 6) NULL,
	[ysnSwap] bit,
	[intSwapContractTypeId] INT NULL, 
	[dtmSwapMaturityDate] DATETIME NULL, 
    [dblSwapContractAmount] NUMERIC(18, 6) NULL, 
    [dblSwapExchangeRate] NUMERIC(18, 6) NULL, 
    [dblSwapMatchAmount] NUMERIC(18, 6) NULL, 
	[ysnSwapConfirm] BIT NULL,  
	
    CONSTRAINT [PK_tblRKFutOptTransaction_intFutOptTransactionId] PRIMARY KEY (intFutOptTransactionId),	
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
	CONSTRAINT [FK_tblRKFutOptTransaction_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY(intCurrencyExchangeRateTypeId)REFERENCES [dbo].[tblSMCurrencyExchangeRateType] (intCurrencyExchangeRateTypeId),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank] ([intBankId]),
	CONSTRAINT [FK_tblRKFutOptTransaction_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId])
)