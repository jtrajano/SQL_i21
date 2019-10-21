﻿CREATE TABLE [dbo].[tblRKM2MInquiry]
(
	[intM2MInquiryId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[strRecordName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intM2MBasisId] INT NULL, 
    [intFutureSettlementPriceId] INT NOT NULL, 
    [intUnitMeasureId] INT NOT NULL, 
    [intPriceItemUOMId] INT NOT NULL, 
    [intCurrencyId] INT NOT NULL, 
    [dtmTransactionUpTo] DATETIME NULL, 
    [strRateType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intCommodityId] INT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intMarketZoneId] INT NULL, 
    [ysnByProducer] BIT NULL, 
	[strPricingType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmGLPostDate] datetime NULL,
	[dtmGLReverseDate] datetime NULL,
	[dtmLastReversalPostDate] datetime NULL,
	[ysnPost] BIT NULL,
	[dtmPostedDateTime] datetime NULL,
	[strBatchId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmCreateDateTime] datetime NULL,
	[dtmUnpostedDateTime] datetime NULL,
	intCompanyId		  INT,
    CONSTRAINT [PK_tblRKM2MInquiry_intM2MInquiryId] PRIMARY KEY (intM2MInquiryId),   
	CONSTRAINT [UK_tblRKM2MInquiry_strRecordName] UNIQUE ([strRecordName]),
	CONSTRAINT [FK_tblRKM2MInquiry_tblRKM2MBasis_intM2MBasisId] FOREIGN KEY(intM2MBasisId)REFERENCES [dbo].[tblRKM2MBasis] (intM2MBasisId),
	CONSTRAINT [FK_tblRKM2MInquiry_tblSMCurrency_intCurrencyId] FOREIGN KEY(intCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblRKM2MInquiry_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [dbo].[tblICCommodity] ([intCommodityId]), 
	CONSTRAINT [FK_tblRKM2MInquiry_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY(intCompanyLocationId)REFERENCES [dbo].[tblSMCompanyLocation] (intCompanyLocationId),
	CONSTRAINT [FK_tblRKM2MInquiry_tblARMarketZone_intMarketZoneId] FOREIGN KEY(intMarketZoneId)REFERENCES [dbo].[tblARMarketZone] (intMarketZoneId),
	CONSTRAINT [FK_tblRKM2MInquiry_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY(intUnitMeasureId)REFERENCES [dbo].[tblICUnitMeasure] (intUnitMeasureId)
)