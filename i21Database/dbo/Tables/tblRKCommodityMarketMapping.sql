CREATE TABLE [dbo].[tblRKCommodityMarketMapping]
(
	[intCommodityMarketId] [INT]  IDENTITY(1,1) NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKCommodityMarketMapping_intCommodityMarketId] PRIMARY KEY ([intCommodityMarketId]), 
    CONSTRAINT [FK_tblRKCommodityMarketMapping_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKCommodityMarketMapping_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
    
)
