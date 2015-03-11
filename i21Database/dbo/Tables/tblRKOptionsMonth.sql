CREATE TABLE [dbo].[tblRKOptionsMonth]
(
	[intOptionMonthId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,	
	[strOptionMonth] nvarchar(20)  COLLATE Latin1_General_CI_AS NOT NULL,
   	[intFutureMarketId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKOptionsMonth_intOptionMonthId] PRIMARY KEY ([intOptionMonthId]), 
    CONSTRAINT [FK_tblRKOptionsMonth_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId])

)