CREATE TABLE [dbo].[tblCTLimit]
(
	[intLimitId] INT NOT NULL IDENTITY, 
	[intBookId] INT NULL,
    [intFutureMarketId] INT NULL, 
    [intFutureMonthId] INT NULL, 
    [intCommodityId] INT  NULL,
	[intSubBookId] INT  NULL,
	[dblLimit] NUMERIC(18,6) NULL,
	[intConcurrencyId] INT  NULL, 
    CONSTRAINT [PK_tblCTLimit_intLimitId] PRIMARY KEY CLUSTERED ([intLimitId] ASC),   
	CONSTRAINT [UK_tblCTLimit_intBookId_intFutureMarketId_intCommodityId_intSubBookId_intFutureMonthId] UNIQUE (intBookId,intFutureMarketId,intCommodityId,intSubBookId,intFutureMonthId),	  
	CONSTRAINT [FK_tblCTLimit_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [tblICCommodity] ([intCommodityId]),
	CONSTRAINT [FK_tblCTLimit_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblCTLimit_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]),
	CONSTRAINT [FK_tblCTLimit_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId]),
	CONSTRAINT [FK_tblCTLimit_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]) ON DELETE CASCADE
)