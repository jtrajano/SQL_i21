CREATE TABLE [dbo].[tblRKM2MInquiryLatestMarketPrice]
(
	[intM2MInquiryLatestMarketPriceId] INT IDENTITY(1,1) NOT NULL,
	[intM2MInquiryId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [intFutureMarketId] INT  NULL, 
    [intFutureMonthId] INT  NULL,
	[intFutSettlementPriceMonthId] INT  NULL,
    [dblClosingPrice] NUMERIC(18, 6) NULL, 
    
    CONSTRAINT [PK_tblRKM2MInquiryLatestMarketPrice_intM2MInquiryLatestMarketPriceId] PRIMARY KEY (intM2MInquiryLatestMarketPriceId),
	CONSTRAINT [FK_tblRKM2MInquiryLatestMarketPrice_tblRKM2MInquiry_intM2MInquiryId] FOREIGN KEY([intM2MInquiryId])REFERENCES [dbo].[tblRKM2MInquiry] (intM2MInquiryId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKM2MInquiryLatestMarketPrice_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY(intFutureMarketId)REFERENCES [dbo].[tblRKFutureMarket] (intFutureMarketId),
	CONSTRAINT [FK_tblRKM2MInquiryLatestMarketPrice_tblRKFuturesMonth_intFutureMonthId] FOREIGN KEY(intFutureMonthId)REFERENCES [dbo].[tblRKFuturesMonth] (intFutureMonthId),
		
)
