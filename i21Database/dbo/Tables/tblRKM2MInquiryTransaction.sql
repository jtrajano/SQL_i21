﻿CREATE TABLE [dbo].[tblRKM2MInquiryTransaction]
(
	[intM2MInquiryTransactionId] INT IDENTITY(1,1) NOT NULL,	
    [intConcurrencyId] INT NOT NULL, 
    [intM2MInquiryId] INT NOT NULL, 
    [strContractOrInventoryType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [strContractSeq] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL, 
    [intEntityId] INT NULL, 
    [intFutureMarketId] INT NULL, 
    [intFutureMonthId] INT NULL, 
    [dblOpenQty] NUMERIC(24, 6) NULL, 
    [intCommodityId] INT NULL,
    [intItemId] INT NULL,
    [strOriginDest] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPosition] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [strPeriod] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [strPriOrNotPriOrParPriced] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [strPricingType] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [dblContractBasis] NUMERIC(24, 6) NULL,
    [dblFutures] NUMERIC(24, 6) NULL,
    [dblCash] NUMERIC(24, 6) NULL,
    [dblContractPrice] NUMERIC(24, 6) NULL,
    [dblCosts] NUMERIC(24, 6) NULL,
    [dblAdjustedContractPrice] NUMERIC(24, 6) NULL,    
    [dblMarketBasis] NUMERIC(24, 6) NULL,
    [dblFuturePrice] NUMERIC(24, 6) NULL,
    [dblContractCash]  NUMERIC(24, 6) NULL,
    [dblMarketPrice] NUMERIC(24, 6) NULL,
    [dblResult] NUMERIC(24, 6) NULL,
    [dblResultBasis] NUMERIC(24, 6) NULL,
    [dblMarketFuturesResult] NUMERIC(24, 6) NULL,
    [dblResultCash] NUMERIC(24, 6) NULL,    
	[intContractHeaderId] int null, 
    [dtmPlannedAvailabilityDate] DATETIME NULL, 
	[intContractDetailId] int NULL,
	[dblPricedQty] NUMERIC(24, 6) NULL,
	[dblUnPricedQty] NUMERIC(24, 6) NULL,
	[dblPricedAmount] NUMERIC(24, 6) NULL,
	[intCompanyLocationId] int NULL,
	[intMarketZoneId] int NULL,
    CONSTRAINT [PK_tblRKM2MInquiryTransaction_intM2MInquiryTransactionId] PRIMARY KEY (intM2MInquiryTransactionId),
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblRKM2MInquiry_intM2MInquiryId] FOREIGN KEY([intM2MInquiryId])REFERENCES [dbo].[tblRKM2MInquiry] (intM2MInquiryId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY(intFutureMarketId)REFERENCES [dbo].[tblRKFutureMarket] (intFutureMarketId),
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY(intFutureMonthId)REFERENCES [dbo].[tblRKFuturesMonth] (intFutureMonthId),
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [dbo].[tblICCommodity] ([intCommodityId]),	
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblICItem_intItemId] FOREIGN KEY([intItemId])REFERENCES [dbo].[tblICItem] ([intItemId]),	
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblEMEntity_intEntityId] FOREIGN KEY([intEntityId])REFERENCES [dbo].tblEMEntity ([intEntityId]),
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblARMarketZone_intMarketZoneId] FOREIGN KEY(intMarketZoneId)REFERENCES [dbo].[tblARMarketZone] (intMarketZoneId),
	CONSTRAINT [FK_tblRKM2MInquiryTransaction_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY(intCompanyLocationId)REFERENCES [dbo].[tblSMCompanyLocation] (intCompanyLocationId)
)