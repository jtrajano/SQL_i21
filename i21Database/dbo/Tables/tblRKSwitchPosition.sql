CREATE TABLE [dbo].[tblRKSwitchPosition]
(
	[intSwitchPositionId] INT IDENTITY(1,1) NOT NULL,
	[strSwitchPositionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [dtmCreationDate] DATETIME NOT NULL,  
	[intCommodityId] INT NOT NULL, 
    [intFutureMarketId] INT NOT NULL, 
	[intFutureMonthId] INT  NULL, 
	[dblSwitchCost]  NUMERIC(18, 6) NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblRKSwitchPosition_intSwitchPositionId] PRIMARY KEY ([intSwitchPositionId]), 
	CONSTRAINT [FK_tblRKSwitchPosition_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblRKSwitchPosition_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]),
	CONSTRAINT [FK_tblRKSwitchPosition_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId])
)