CREATE TABLE [dbo].[tblRKM2MGrainBasis]
(
	[intM2MGrainBasisId] INT IDENTITY(1,1) NOT NULL,
	[intM2MBasisId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
	[intCommodityId] INT  NULL, 
	[intFutureMarketId] INT  NULL, 
	[strDeliveryMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intFutureMonthId] INT NULL, 
    [dblBasis] NUMERIC(18, 6) NULL

	CONSTRAINT [PK_tblRKM2MGrainBasis_intM2MGrainBasisId] PRIMARY KEY (intM2MGrainBasisId),
	CONSTRAINT [FK_tblRKM2MGrainBasis_tblRKM2MBasis_intM2MBasisId] FOREIGN KEY ([intM2MBasisId]) REFERENCES [dbo].[tblRKM2MBasis] ([intM2MBasisId]) ON DELETE CASCADE, 
	CONSTRAINT [UK_tblRKM2MGrainBasis_intM2MBasisId_intCommodityId_strDeliveryMonth] UNIQUE ([intM2MBasisId] , [intCommodityId], [strDeliveryMonth]), 
	CONSTRAINT [FK_tblRKM2MGrainBasis_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [dbo].[tblICCommodity] ([intCommodityId]),  
	CONSTRAINT [FK_tblRKM2MGrainBasis_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY (intFutureMarketId) REFERENCES [dbo].[tblRKFutureMarket] (intFutureMarketId),
	CONSTRAINT [FK_tblRKM2MGrainBasis_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY (intFutureMonthId) REFERENCES [dbo].[tblRKFuturesMonth] (intFutureMonthId)
)