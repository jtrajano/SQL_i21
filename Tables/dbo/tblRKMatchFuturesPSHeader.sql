﻿CREATE TABLE [dbo].[tblRKMatchFuturesPSHeader]
(
	[intMatchFuturesPSHeaderId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[intMatchNo] INT NOT NULL, 
    [dtmMatchDate] DATETIME NOT NULL, 
	[intCompanyLocationId] INT NULL, 
	[intCommodityId] INT NULL, 
	[intFutureMarketId] INT NULL, 
	[intFutureMonthId] int NULL, 
	[intEntityId] INT NULL, 
	[intBrokerageAccountId] INT NULL, 
	[intBookId] INT NULL, 
    [intSubBookId] INT NULL,
	[intSelectedInstrumentTypeId] INT NULL,
	[strType] NVARCHAR(10) COLLATE Latin1_General_CI_AS DEFAULT (N'Realize'),
	[intCurrencyExchangeRateTypeId] INT NULL,
	[intBankId] INT NULL,
	[intBankAccountId] INT NULL,
    [ysnPosted] BIT NULL, 
	[intCompanyId] INT NULL,
	[strRollNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblRKMatchFuturesPSHeader_intMatchFuturesPSHeaderId] PRIMARY KEY (intMatchFuturesPSHeaderId), 
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY(intCurrencyExchangeRateTypeId)REFERENCES [dbo].[tblSMCurrencyExchangeRateType] (intCurrencyExchangeRateTypeId),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank] ([intBankId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId]),
    CONSTRAINT [UK_tblRKMatchFuturesPSHeader_intMatchNo] UNIQUE (intMatchNo)
)