CREATE TABLE [dbo].[tblRKMatchFuturesPSHeader]
(
	[intMatchFuturesPSHeaderId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[intMatchNo] INT NOT NULL, 
    [dtmMatchDate] DATETIME NOT NULL, 
	[intCompanyLocationId] INT NOT NULL, 
	[intCommodityId] INT NOT NULL, 
	[intFutureMarketId] INT NOT NULL, 
	[intFutureMonthId] int NOT NULL, 
	[intBrokerId] INT NOT NULL, 
	[intBrokerageAccountId] INT NOT NULL, 
	[intBookId] INT NULL, 
    [intSubBookId] INT NULL
    CONSTRAINT [PK_tblRKMatchFuturesPSHeader_intMatchFuturesPSHeaderId] PRIMARY KEY (intMatchFuturesPSHeaderId), 
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblRKBrokerageAccount_intBrokerageAccountId] FOREIGN KEY ([intBrokerageAccountId]) REFERENCES [tblRKBrokerageAccount]([intBrokerageAccountId]),
	CONSTRAINT [FK_tblRKMatchFuturesPSHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),

    CONSTRAINT [UK_tblRKMatchFuturesPSHeader_intMatchNo] UNIQUE (intMatchNo)
)

