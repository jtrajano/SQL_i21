﻿CREATE TABLE [dbo].[tblRKM2MInquiryBasisDetail]
(
	[intM2MInquiryBasisDetailId] INT IDENTITY(1,1) NOT NULL,
	[intM2MInquiryId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [intCommodityId] INT NULL, 
    [intItemId] INT NULL, 
	[strOriginDest] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intFutureMarketId] INT  NULL, 
    [intFutureMonthId] INT  NULL, 
    [strPeriodTo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intCompanyLocationId] INT NULL, 
    [intMarketZoneId] INT NULL, 
    [intCurrencyId] INT NULL, 
    [intPricingTypeId] INT NULL, 
    [strContractInventory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intContractTypeId] INT NULL, 
    [dblCashOrFuture] NUMERIC(18, 6) NULL, 
    [dblBasisOrDiscount] NUMERIC(18, 6) NULL, 
	[dblRatio] NUMERIC(18, 6) NULL, 
    [intUnitMeasureId] INT NULL, 
    [intM2MBasisDetailId] INT NULL, 
    CONSTRAINT [PK_tblRKM2MInquiryBasisDetail_intM2MInquiryBasisDetailId] PRIMARY KEY (intM2MInquiryBasisDetailId),
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblRKM2MInquiry_intM2MInquiryId] FOREIGN KEY([intM2MInquiryId])REFERENCES [dbo].[tblRKM2MInquiry] (intM2MInquiryId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [dbo].[tblICCommodity] ([intCommodityId]),  
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblICItem_intItemId] FOREIGN KEY(intItemId)REFERENCES [dbo].[tblICItem] (intItemId),  
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY(intFutureMarketId)REFERENCES [dbo].[tblRKFutureMarket] (intFutureMarketId),
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY(intFutureMonthId)REFERENCES [dbo].[tblRKFuturesMonth] (intFutureMonthId),
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY(intCompanyLocationId)REFERENCES [dbo].[tblSMCompanyLocation] (intCompanyLocationId),
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblARMarketZone_intMarketZoneId] FOREIGN KEY(intMarketZoneId)REFERENCES [dbo].[tblARMarketZone] (intMarketZoneId),
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblSMCurrency_intCurrencyId] FOREIGN KEY(intCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblRKM2MInquiryBasisDetail_tblCTContractType_intContractTypeId] FOREIGN KEY(intContractTypeId)REFERENCES [dbo].[tblCTContractType] (intContractTypeId)
)