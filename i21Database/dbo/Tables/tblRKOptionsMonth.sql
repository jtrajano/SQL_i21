CREATE TABLE [dbo].[tblRKOptionsMonth]
(
	[intOptionMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,	
	[intFutureMarketId] INT NOT NULL,
	[strOptionMonth] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL ,  
	[intYear] INT NOT NULL, 
    [intFutureMonthId] INT NULL, 
    [ysnMonthExpired] BIT NULL, 
    [dtmExpirationDate] DATETIME NULL, 
    [strOptMonthSymbol] NCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblRKOptionsMonth_intOptionMonthId] PRIMARY KEY ([intOptionMonthId]), 
    CONSTRAINT [FK_tblRKOptionsMonth_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKOptionsMonth_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]), 
    CONSTRAINT [UK_tblRKOptionsMonth_intFutureMarketId_strOptionMonth] UNIQUE (intFutureMarketId, strOptionMonth)
    
)