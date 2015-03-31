CREATE TABLE [dbo].[tblRKFuturesMonth]
(
	[intFutureMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[strFutureMonth] nvarchar(20)  COLLATE Latin1_General_CI_AS NOT NULL,
	[intFutureMarketId] INT NOT NULL, 
	[dtmFutureMonthsDate] DATETIME NULL, 
	[strSymbol] NVARCHAR(4)  COLLATE Latin1_General_CI_AS NOT NULL, 
    [intYear] INT NOT NULL, 
    [dtmFirstNoticeDate] DATETIME NULL, 
    [dtmLastNoticeDate] DATETIME NULL, 
    [dtmLastTradingDate] DATETIME NULL, 
    [dtmSpotDate] DATETIME NOT NULL, 
    [ysnExpired] BIT NOT NULL, 
   	CONSTRAINT [PK_tblRKFuturesMonth_intFuturesMonthId] PRIMARY KEY ([intFutureMonthId]), 
CONSTRAINT [FK_tblRKFuturesMonth_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId])
)