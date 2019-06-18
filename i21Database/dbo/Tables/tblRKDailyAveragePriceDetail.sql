CREATE TABLE [dbo].[tblRKDailyAveragePriceDetail]
(
	[intDailyAveragePriceDetailId] INT NOT NULL IDENTITY, 
    [intDailyAveragePriceId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
    [intCommodityId] INT NOT NULL, 
    [intFutureMonthId] INT NOT NULL, 
    [dblNoOfLots] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblAverageLongPrice] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblSwitchPL] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblOptionsPL] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblNetLongAvg] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intBrokerId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblRKDailyAveragePriceDetail] PRIMARY KEY ([intDailyAveragePriceDetailId]), 
    CONSTRAINT [FK_tblRKDailyAveragePriceDetail_tblRKDailyAveragePrice] FOREIGN KEY ([intDailyAveragePriceId]) REFERENCES [tblRKDailyAveragePrice]([intDailyAveragePriceId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKDailyAveragePriceDetail_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKDailyAveragePriceDetail_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblRKDailyAveragePriceDetail_tblRKFuturesMonth] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]), 
    CONSTRAINT [FK_tblRKDailyAveragePriceDetail_tblEMEntity] FOREIGN KEY ([intBrokerId]) REFERENCES [tblEMEntity]([intEntityId])
)
