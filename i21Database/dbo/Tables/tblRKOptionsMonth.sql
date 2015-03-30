CREATE TABLE [dbo].[tblRKOptionsMonth]
(
	[intOptionMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,	
	[intFutureMarketId] INT NOT NULL,
	[strOptionMonth] NVARCHAR(20)  COLLATE Latin1_General_CI_AS NOT NULL ,  
    [intFutureMonthId] INT NOT NULL, 
    [strOptionMonthId] NVARCHAR(20)  COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnMonthExpired] BIT NULL, 
    [Expiration Date] DATETIME NULL, 
    CONSTRAINT [PK_tblRKOptionsMonth_intOptionMonthId] PRIMARY KEY ([intOptionMonthId]), 
    CONSTRAINT [FK_tblRKOptionsMonth_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKOptionsMonth_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
)