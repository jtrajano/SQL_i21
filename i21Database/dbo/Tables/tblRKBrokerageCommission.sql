CREATE TABLE [dbo].[tblRKBrokerageCommission]
(
	[intBrokerageCommissionId] INT IDENTITY(1,1) NOT NULL,   
    [intBrokerageAccountId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [dtmEffectiveDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NOT NULL, 
    [intFuturesRateType] INT NULL , 
    [dblFutCommission] NUMERIC(18, 6) NULL, 
    [intFutCurrencyId] INT NULL, 
    [intOptionsRateType] INT NULL, 
    [dblOptCommission] NUMERIC(18, 6) NULL, 
    [intOptCurrencyId] INT NULL,
    [intFutureMarketId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKBrokerageCommission_intBrokerageCommissionId] PRIMARY KEY ([intBrokerageCommissionId]), 
	CONSTRAINT [FK_tblRKBrokerageCommission_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblRKBrokerageCommission_tblSMCurrency_intFutCurrencyId] FOREIGN KEY ([intFutCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
	CONSTRAINT [FK_tblRKBrokerageCommission_tblSMCurrency_intOptCurrencyId] FOREIGN KEY ([intOptCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblRKBrokerageCommission_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId])
	)

