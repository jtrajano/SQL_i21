﻿CREATE TABLE [dbo].[tblRKM2MTransaction]
(
	[intM2MTransactionId] INT NOT NULL IDENTITY, 
    [intM2MHeaderId] INT NOT NULL, 
	[strContractOrInventoryType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strContractSeq] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [intEntityId] INT NULL, 
	[strEntityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
    [intFutureMarketId] INT NULL, 
	[strFutureMarket] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
    [intFutureMonthId] INT NULL, 
	[strFutureMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
    [dblOpenQty] NUMERIC(24, 6) NULL, 
    [intCommodityId] INT NULL,
	[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
    [intItemId] INT NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strOrgin] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
    [strOriginDest] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPosition] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [strPeriod] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[strPeriodTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strStartDate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strEndDate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strPriOrNotPriOrParPriced] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[intPricingTypeId] INT NULL,
    [strPricingType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
	[intContractTypeId] INT NULL,
    [dblContractBasis] NUMERIC(24, 6) NULL,
	[dblContractRatio] NUMERIC(24, 6) NULL,
    [dblFutures] NUMERIC(24, 6) NULL,
    [dblCash] NUMERIC(24, 6) NULL,
    [dblContractPrice] NUMERIC(24, 6) NULL,
    [dblCosts] NUMERIC(24, 6) NULL,
    [dblAdjustedContractPrice] NUMERIC(24, 6) NULL,    
    [dblMarketBasis] NUMERIC(24, 6) NULL,
	[dblMarketRatio] NUMERIC(24, 6) NULL,
    [dblFuturePrice] NUMERIC(24, 6) NULL,
    [dblContractCash]  NUMERIC(24, 6) NULL,
    [dblMarketPrice] NUMERIC(24, 6) NULL,
    [dblResult] NUMERIC(24, 6) NULL,
    [dblResultBasis] NUMERIC(24, 6) NULL,
	[dblResultRatio] NUMERIC(24, 6) NULL,
    [dblMarketFuturesResult] NUMERIC(24, 6) NULL,
    [dblResultCash] NUMERIC(24, 6) NULL,
	[dblCashPrice] NUMERIC(24, 6) NULL,
	[intQuantityUOMId] INT NULL,
	[intCommodityUnitMeasureId] INT NULL,
	[intPriceUOMId] INT NULL,
	[intCent] INT NULL,
	[intContractHeaderId] INT NULL, 
    [dtmPlannedAvailabilityDate] DATETIME NULL, 
	[intContractDetailId] INT NULL,
	[dblPricedQty] NUMERIC(24, 6) NULL,
	[dblUnPricedQty] NUMERIC(24, 6) NULL,
	[dblPricedAmount] NUMERIC(24, 6) NULL,
	[intSpreadMonthId] INT NULL,
	[strSpreadMonth] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblSpreadMonthPrice] NUMERIC(24, 6) NULL,
	[dblSpread] NUMERIC(24, 6) NULL,
	[intLocationId] INT NULL,	
	[strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intMarketZoneId] INT NULL,
	[strMarketZoneCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblRKM2MTransaction] PRIMARY KEY ([intM2MTransactionId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblRKM2MHeader] FOREIGN KEY ([intM2MHeaderId]) REFERENCES [tblRKM2MHeader]([intM2MHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblRKM2MTransaction_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblRKFuturesMonth] FOREIGN KEY ([intFutureMonthId]) REFERENCES [tblRKFuturesMonth]([intFutureMonthId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblARMarketZone] FOREIGN KEY ([intMarketZoneId]) REFERENCES [tblARMarketZone]([intMarketZoneId]), 
    CONSTRAINT [FK_tblRKM2MTransaction_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
